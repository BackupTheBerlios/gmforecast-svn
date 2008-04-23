#!sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

#Описание формата
#TOWN     информация о пункте прогнозирования:
#  index     уникальный пятизначный код города
#  sname     закодированное название города
#  latitude     широта в целых градусах
# longitude     долгота в целых градусах
#FORECAST     информация о сроке прогнозирования:
#  day, month, year     дата, на которую составлен прогноз в данном блоке
#  hour     местное время, на которое составлен прогноз
#  tod     время суток, для которого составлен прогноз: 0 - ночь 1 - утро, 2 - день, 3 - вечер
#  weekday     день недели, 1 - воскресенье, 2 - понедельник, и т.д.
#  predict     заблаговременность прогноза в часах
#PHENOMENA      атмосферные явления:
#  cloudiness     облачность по градациям:  0 - ясно, 1- малооблачно, 2 - облачно, 3 - пасмурно
#  precipitation     тип осадков: 4 - дождь, 5 - ливень, 6,7 – снег, 8 - гроза, 9 - нет данных, 10 - без осадков
#  rpower     интенсивность осадков, если они есть. 0 - возможен дождь/снег, 1 - дождь/снег
#  spower     вероятность грозы, если прогнозируется: 0 - возможна гроза, 1 - гроза
#PRESSURE     атмосферное давление, в мм.рт.ст.
#TEMPERATURE     температура воздуха, в градусах Цельсия
#WIND     приземный ветер
#  min, max     минимальное и максимальное значения средней скорости ветра, без порывов
#  direction      направление ветра в румбах, 0 - северный, 1 - северо-восточный,  и т.д.
#RELWET     относительная влажность воздуха, в %
#HEAT     комфорт - температура швоздуха по ощущению одетого по сезону человека, выходящего на улицу

package require tdom
package require http

# Файлик нужно сливать и записывать как темповый, потом анализировать уже его, в конце анализа удалять.
set odessa_token [http::geturl http://informer.gismeteo.ua/xml/33837_1.xml]
set odessa_data [http::data $odessa_token]

set odessa_doc [dom parse $odessa_data]
#set root [$odessa_doc documentElement]
set hours [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@hour]
set days [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@day]
set months [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@month]
set years [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@year]


foreach day_numb $days hour_numb $hours month_numb $months year_numb $years {
set day [lindex $day_numb 1]
set hour [lindex $hour_numb 1]
set month [lindex $month_numb 1]
set year [lindex $year_numb 1]
set rpower [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@rpower)}]
set spower [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@spower)}]

set cloudiness [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@cloudiness)}]
switch -exact -- $cloudiness {
    0 {set sky "Ясно"}
    1 {set sky "Малооблачно"}
    2 {set sky "Облачно"}
    3 {set sky "Пасмурно"}
}
set precipitation_xml [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@precipitation)}]
switch -exact -- $precipitation_xml {
    4 {set precipitation "Дождь"}
    5 {set precipitation "Ливень"}
    6 {set precipitation "Снег"}
    7 {set precipitation "Снег"}
    8 {set precipitation "Гроза"}
    9 {set precipitation "Нет данных"}
    10 {set precipitation "Без осадков"}
}

set weekday_xml [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/@weekday)}]
switch -exact -- $weekday_xml {
    1 {set weekday "Воскресенье"}
    2 {set weekday "Понедельник"}
    3 {set weekday "Вторник"}
    4 {set weekday "Среда"}
    5 {set weekday "Четверг"}
    6 {set weekday "Пятница"}
    7 {set weekday "Суббота"}
}

puts "Дата: $day $month $year $weekday Время: $hour"
puts "Temp max: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/TEMPERATURE/@max)}]"
puts "Temp min: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/TEMPERATURE/@min)}]"
puts "Время суток: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/@tod)}]"
puts "Атмосферные явления: $sky $precipitation"

puts "\n"
}

#FORECAST day="17" month="4" year="2008" hour="21" tod="3" predict="18" weekday="5">
#<PHENOMENA cloudiness="2" precipitation="10" rpower="0" spower="0"/>
#<PRESSURE max="755" min="753"/>
#<TEMPERATURE max="10" min="8"/>
#<WIND min="3" max="6" direction="4"/>
#<RELWET max="65" min="60"/>
#<HEAT min="7" max="9"/>
#</FORECAST>


