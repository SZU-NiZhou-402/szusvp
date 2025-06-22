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
对于各个模块的选型和功能已在调研报告中描述，此处不再赘述

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

GPIO4~7

== USBC接口
#hrule()
#figure(
  image("image/USBC.png"),
  caption: "USB-C接口电路拓扑",
)
USB-C接口的电路拓扑，其中D+和D-用于连接到ESP32芯片作为通信口，方便程序烧录和通信

其中CC1和CC2用于USB-C供电功率的通信，不过我们的设备不需要快充，因此直接将其接一个5.1KΩ电阻接地即可

#figure(
  image("image/MAX.png"),
  caption: "音频处理芯片",
)
其中BCLK、LRCLK、DIN为I2S标准数字音频接口，连接到ESP32芯片传输音频数据

#figure(
  image("image/flash.png"),
  caption: "外部Flash芯片",
)
暴露出标准的SPI接口

#figure(
  image("image/clock.png"),
  caption: "外部石英晶振和复位电路",
)
负责提供数字系统时钟和复位信号

此处复位按键的电容用于滤波，防止按键抖动

== PCB设计
#figure(
  image("image/pcb.png"),
  caption: "PCB设计图",
)

挖掉陶瓷天线(U6)的铺铜，防止干扰
周围铺铜加上过孔以降低接地阻抗，提升抗干扰能力，同时阻抗线圆弧走线以降低阻抗