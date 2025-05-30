#set heading(numbering: (..num) => if num.pos().len() < 5 {
  numbering("1.1", ..num)
})

#let hrule(length: 100%, stroke: gray + 1pt) = {
  line(length: length, stroke: stroke)
}

#let imageonside(lefttext, rightimage, bottomtext: none, marginleft: 0em, margintop: 0.5em) = {
  set par(justify: true)
  grid(columns: 2, column-gutter: 1em, lefttext, rightimage)
  set par(justify: false)
  block(inset: (left: marginleft, top: -margintop), bottomtext)
}

#set text(font: ("Sarasa Term SC Nerd"))

#counter(heading).update(5)

= 硬件技术
#hrule()
本章节详细介绍了“基于云边端大模型语音交互助手”项目的硬件构成，围绕核心开发板“ESP32-S3 PICO”展开，分析了其主体架构、关键芯片选型以及相关的外围硬件模块。

== 主体架构
#hrule()
嵌入式系统的主体架构多种多样，常见的有
- 基于微控制器 (MCU) 的架构：例如STM32系列、AVR系列、ESP32系列等。这类架构通常集成度高，片上包含CPU核心、Flash、RAM以及丰富的外设接口（GPIO, SPI, I2C, UART, ADC/DAC等）。功耗较低，成本效益好，适合于控制密集型、实时性要求高的应用。
- 基于微处理器 (MPU) + 外部存储的架构：例如ARM Cortex-A系列（如树莓派使用的博通BCM系列芯片）。这类架构通常性能更强，可以运行完整的操作系统（如Linux），拥有更大的内存和存储空间。适合于计算密集型、需要复杂应用和网络服务的场景。功耗和成本相对较高。
- 基于FPGA的架构：现场可编程门阵列，硬件逻辑可定制，并行处理能力强，灵活性高。适用于特定算法加速、高速接口等场景，开发难度和成本较高。
- 专用集成电路 (ASIC)：为特定功能定制的芯片，性能和功耗最优，但研发周期长，初始成本极高，不具备灵活性。
#hrule()
我们的需求
- 即使经过蒸馏和剪枝，想要运行LLM依旧需要非常强大的cpu算力，同时，为了开发板其他任务不被拖慢，我们最好能够选择有多个核心的soc
- 大多数开发板有内置的flash以存储程序，但是要存储LLM模型显然不足，因此最好选择有外接大容量flash芯片的开发板
- 为了灵活期间，最好还有常见的无线功能(wifi/蓝牙/红外)等
- 为了方便使用，最好能够有良好的软件生态和丰富的外设接口
#hrule()
最后综合考虑成本，算力和灵活性，我们选择ESP32-S3 PICO开发板。\
本项目采用的 ESP32-S3 PICO 开发板 属于典型的基于MCU的架构。其核心是乐鑫（Espressif）的ESP32-S3系列芯片。 该开发板的架构特点如下：

#imageonside([
  \
  - 高度集成：主控芯片ESP32-S3集成了处理器核心、Wi-Fi和蓝牙模块、PSRAM（部分型号）、以及多种外设控制器。ESP32-S3 PICO板在此基础上进一步集成了USB转串口、Flash存储、晶体振荡器、天线以及必要的电源管理电路，形成了小巧而功能完整的系统。
  \
  - 低功耗设计：ESP32-S3芯片本身支持多种低功耗模式，配合RTOS可以实现高效的电源管理，适合电池供电或对功耗有要求的边缘设备。
], figure(
  image("image/esp32-pico.png", width: 90%),
  caption: "ESP32-S3-Pico开发板",
), bottomtext: [
  - 接口丰富：引出了大部分ESP32-S3的可用GPIO，支持SPI、I2C、UART、I2S、ADC等，方便连接各类传感器（如麦克风）、执行器（如功放和扬声器）和显示设备。
  - 特定优化：ESP32-S3芯片包含用于加速神经网络计算的向量指令，这对于在端侧运行蒸馏剪枝后的小型LLM模型具有重要意义，使其能够在资源受限的设备上实现更快的响应。
  - 紧凑尺寸：PICO板型设计紧凑，便于集成到小型化产品原型中
])

该架构非常适合本项目的需求：通过I2S接口连接收音和功放芯片进行语音数据的采集和播放，利用ESP32-S3的计算能力运行本地LLM进行初步指令识别和响应，并通过Wi-Fi/蓝牙与云端或边缘计算节点通信，实现更复杂的语音交互功能。

== 主控芯片
#hrule()
主控芯片是整个硬件系统的核心，负责运行程序、处理数据、控制外设。常见的选型有：
- STM32系列(STMicroelectronics)\ 
  基于ARM Cortex-M内核，产品线非常广泛，从低功耗M0到高性能M7，外设丰富，生态成熟，是工业控制和消费电子领域的常用选择。
- nRF系列 (Nordic Semiconductor)\
  主打低功耗蓝牙 (BLE)，其SoC集成了ARM Cortex-M内核和高质量的无线射频单元，广泛用于可穿戴设备、物联网终端。
- ESP32系列 (Espressif Systems)\
  基于Tensilica Xtensa LX系列内核，以高性价比的Wi-Fi和蓝牙连接功能著称，近年来在AIoT领域发展迅速，推出了支持AI加速指令的S3、C3等系列。
- 树莓派RP2040 (Raspberry Pi Foundation)\
  双核ARM Cortex-M0+，独特的PIO（可编程I/O）是其特色，性价比高，社区活跃。
#hrule()
本项目选用的是 ESP32-S3R8 芯片，具体说明如下：
- 核心与性能
  - 采用双核 32 位 Xtensa® LX7 微处理器，主频高达 240 MHz。
  - 内置 512 KB SRAM，本项目选用的ESP32-S3 PICO板上额外通过SPI接口连接了 8MB PSRAM (Pseudo Static RAM)，为运行LLM模型提供了必要的内存空间。
  - 支持 AI 加速向量指令，可显著提升神经网络运算、信号处理等性能，对于在端侧运行LLM模型至关重要。
- 无线通信
  - 集成 2.4 GHz Wi-Fi (802.11 b/g/n)，支持 Station 模式、SoftAP 模式、SoftAP + Station 模式和混杂模式。
  - 集成 Bluetooth® 5 (LE)，支持低功耗蓝牙，包括高功率模式 (20 dBm) 和长距离支持 (Coded PHY)。
- 存储
  - 支持高达 1GB 的 Quad SPI Flash 和 PSRAM。本开发板板载 16MB Quad SPI Flash
- 外设接口
  - 多达 45 个可编程 GPIO。
  - 丰富的标准接口：SPI (4个), LCD接口, Camera接口, UART (3个), I2C (2个), I2S (2个), RMT (8通道), ADC (2个, 12位, 多达20通道), DAC (2个, 8位), USB OTG 1.1 等
  - 其中 I2S 接口 对于本项目的语音输入（连接数字麦克风或CODEC）和输出（连接数字功放）至关重要。
- 安全性：支持安全启动、Flash 加密、 cryptographic hardware acceleration (AES, SHA, RSA, ECC)。
== 收音芯片
- 普通电容麦
- MEMS麦克风

== 功放芯片
- A B AB C D类功放(简要描述)
- LM386/358
- MAX9814
- MAX98357AEWL+T

== 闪存芯片
- flash
- W25Q128TVPIQ

== 网络天线
- 大天线
- 小天线
- 陶瓷天线

== 实时操作系统
- rtthread
- RTIC
- freertos
