# Verilog HDL Modules

간단한 모듈 이것저것 올리는 겸, 지수랑 log 함수 지원하는 계산기까지 달려보자.

## List

### Adder
> so easy to implemet. 

위치: `fixed-point-adder-n-multiplier/`

### Multiplier
> partial product (중간 누적합) 방식으로 구현.

위치: `fixed-point-adder-n-multiplier/`

### Decoder(7-segments display)
> DE10-Lite의 6개 7-segments display를 기준. hex(16진수)로 표기한다.

![decoder-seg7](/images/decoder_schema.drawio.png)

~~10진수 하려니 머리가 아파서 16진수로 구현한다.~~

각 자리는 16진수 (0~F)를 나타낸다.