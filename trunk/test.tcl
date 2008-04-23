#!sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

#Описание формата
#TOWN 	информация о пункте прогнозирования:
#  index 	уникальный пятизначный код города
#  sname 	закодированное название города
#  latitude 	широта в целых градусах
# longitude 	долгота в целых градусах
#FORECAST 	информация о сроке прогнозирования:
#  day, month, year 	дата, на которую составлен прогноз в данном блоке
#  hour 	местное время, на которое составлен прогноз
#  tod 	время суток, для которого составлен прогноз: 0 - ночь 1 - утро, 2 - день, 3 - вечер
#  weekday 	день недели, 1 - воскресенье, 2 - понедельник, и т.д.
#  predict 	заблаговременность прогноза в часах
#PHENOMENA  	атмосферные явления:
#  cloudiness 	облачность по градациям:  0 - ясно, 1- малооблачно, 2 - облачно, 3 - пасмурно
#  precipitation 	тип осадков: 4 - дождь, 5 - ливень, 6,7 – снег, 8 - гроза, 9 - нет данных, 10 - без осадков
#  rpower 	интенсивность осадков, если они есть. 0 - возможен дождь/снег, 1 - дождь/снег
#  spower 	вероятность грозы, если прогнозируется: 0 - возможна гроза, 1 - гроза
#PRESSURE 	атмосферное давление, в мм.рт.ст.
#TEMPERATURE 	температура воздуха, в градусах Цельсия
#WIND 	приземный ветер
#  min, max 	минимальное и максимальное значения средней скорости ветра, без порывов
#  direction  	направление ветра в румбах, 0 - северный, 1 - северо-восточный,  и т.д.
#RELWET 	относительная влажность воздуха, в %
#HEAT 	комфорт - температура воздуха по ощущению одетого по сезону человека, выходящего на улицу

package require tdom
package require http

# Файлик нужно сливать и записывать как темповый, потом анализировать уже его, в конце анализа удалять.
set odessa_token [http::geturl http://informer.gismeteo.ua/xml/33837_1.xml]
set odessa_data [http::data $odessa_token]

set odessa_doc [dom parse $odessa_data]
#set root [$odessa_doc documentElement]
set days [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@day]
set months [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@month]
set yars [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@year]


#FORECAST day="17" month="4" year="2008" hour="21" tod="3" predict="18" weekday="5">
#<PHENOMENA cloudiness="2" precipitation="10" rpower="0" spower="0"/>
#<PRESSURE max="755" min="753"/>
#<TEMPERATURE max="10" min="8"/>
#<WIND min="3" max="6" direction="4"/>
#<RELWET max="65" min="60"/>
#<HEAT min="7" max="9"/>
#</FORECAST>
set day 17
puts "Day: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST/@day)}]"
puts "Temp max: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@month='4']/TEMPERATURE/@max)}]"
puts "Temp min: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day]/TEMPERATURE/@min)}]"
puts "Hour: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day]/@hour)}]"

#puts "Agent: [$odessa_doc selectNodes {string(/agents/agent[@id='013']/@id)}]"
#puts "First Name: [$doc selectNodes {string(/agents/agent[@id='013']/name[@type='first'])}]"
#puts "Last Name: [$doc selectNodes {string(/agents/agent[@id='013']/name[@type='last'])}]"
#puts "Age: [$doc selectNodes {string(/agents/agent[@id='013']/age)}]"