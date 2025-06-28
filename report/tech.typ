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

#set text(font: ("Times New Roman", "SimSun"))

#set table(
  fill: (x, y) =>
    if x == 0 or y == 0 { rgb("#917f7f") },
  inset: (right: 1.5em),
)

#show table.cell: it => {
  if it.x == 0 or it.y == 0 {
    set text(white)
    strong(it)
  } else {
    it
  }
}

= 硬件描述
#hrule()
对于各个模块的选型和功能已在调研报告中描述，此处*不再赘述*

此处主要描述各个模块的电路拓扑，PCB设计等

#figure(
  image("image/sch.png"),
  caption: "整体系统原理图",
)

== ESP32-S3 核心板
#hrule()
#figure(
  image("image/esp32-s3.png", width: 90%),
  caption: "ESP32-S3R8芯片",
)
这是ESP32核心板的电路拓扑，其中索引29\~35的引脚，连接到外部flash，作为整个系统的ROM

GPIO4~7暴露出标准I2S总线，用以连接MEMS音频芯片，接收音频数据

GPIO19、20直接连接到USB-C接口的通信引脚，用以程序烧录和串口通信

XTAL_P和XTAL_N连接到外部晶振，提供系统时钟

== USBC接口
#hrule()
#figure(
  image("image/USBC.png"),
  caption: "USB-C接口电路拓扑",
)
USB-C接口的电路拓扑，其中D+和D-用于连接到ESP32芯片作为通信口，方便程序烧录和通信

其中CC1和CC2用于USB-C供电功率的通信，不过我们的设备不需要快充，因此直接将其接一个5.1KΩ下拉电阻即可

== 电源管理芯片
#hrule()
#figure(
  image("image/LDO.png"),
  caption: "ME6217线性稳压器(LDO)",
)
LDO将USB-C接口的5V电源转换为标准3.3V电源，供给ESP32芯片和其他模块

== MEMS音频芯片
#hrule()
#figure(
  image("image/MAX.png"),
  caption: "音频处理芯片",
)
其中BCLK、LRCLK、DIN为I2S标准数字音频接口，连接到ESP32芯片传输音频数据

== FLASH芯片
#hrule()
#figure(
  image("image/flash.png"),
  caption: "外部Flash芯片",
)
暴露出标准的SPI接口

其中的SPI_D0\~D4为数据信号，SPI_CS为片选信号(低有效)，只在片选信号有效时，芯片才会响应SPI总线上的数据传输
SPI_CLK为时钟信号，负责同步SPI总线上的数据传输

== 外部石英晶振
#hrule()
#figure(
  image("image/clock.png"),
  caption: "外部石英晶振和复位电路",
)
负责提供数字系统时钟和复位信号

差分时钟信号XTAL_P和XTAL_N以抗干扰

此处复位按键的电容用于滤波，防止按键抖动

== 陶瓷天线
#hrule()
#figure(
  image("image/wire.png"),
  caption: "陶瓷天线",
)
用于ESP32的无线通信

== PCB设计
#hrule()
#figure(
  image("image/pcb.png"),
  caption: "PCB设计图",
)
pcb双面铺铜，降低地线阻抗、提高抗干扰能力、降低压降和提高电源效率，并减小环路面积，同时挖掉陶瓷天线(U6)的铺铜，并且周围加上过孔以降低接地阻抗，提升抗干扰能力，同时阻抗线圆弧走线以降低阻抗

#figure(
  image("image/pcb3d.png"),
  caption: "PCB3D预览图",
)
