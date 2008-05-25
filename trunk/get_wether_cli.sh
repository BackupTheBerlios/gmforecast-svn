#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

#Описание формата
#<TOWN index="27612" sname="%CC%EE%F1%EA%E2%E0" latitude="56" longitude="38">
#FORECAST day="17" month="4" year="2008" hour="21" tod="3" predict="18" weekday="5">
#<PHENOMENA cloudiness="2" precipitation="10" rpower="0" spower="0"/>
#<PRESSURE max="755" min="753"/>
#<TEMPERATURE max="10" min="8"/>
#<WIND min="3" max="6" direction="4"/>
#<RELWET max="65" min="60"/>
#<HEAT min="7" max="9"/>
#</FORECAST>
#
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

set odessa_token [http::geturl http://informer.gismeteo.ua/xml/33837_1.xml]
set odessa_data [http::data $odessa_token]

set odessa_doc [dom parse $odessa_data]
#set root [$odessa_doc documentElement]
# Town
set sname [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/@sname)}]
set index [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/@index)}]
set latitude [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/@latitude)}]
set longitude [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/@longitude)}]

set hours [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@hour]
set days [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@day]
set months [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@month]
set years [$odessa_doc selectNodes /MMWEATHER/REPORT/TOWN/FORECAST/@year]

foreach day_numb $days hour_numb $hours month_numb $months year_numb $years {
#FORECAST
set day [lindex $day_numb 1]
set hour [lindex $hour_numb 1]
set month [lindex $month_numb 1]
set year [lindex $year_numb 1]
set tod_xml [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/@tod)}]

switch -exact -- $tod_xml {
    0 {set tod "ночь"}
    1 {set tod "утро"}
    2 {set tod "день"}
    3 {set tod "вечер"}
}

# PHENOMENA part
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
    4 {
        if {$rpower == 1} {
        set precipitation "дождь"
        } else {
        set precipitation "возможен дождь"
        }
    }
    5 {set precipitation "ливень"}
    6 {
        if {$rpower == 1} {
        set precipitation "снег"
        } else {
        set precipitation "возможен снег"
        }
    }
    7 {
        if {$rpower == 1} {
        set precipitation "снег"
        } else {
        set precipitation "возможен снег"
        }
    }
    8 {
        if {$rpower == 1} {
        set precipitation "гроза"
        } else {
        set precipitation "возможна гроза"
        }
    }
    9 {set precipitation "информация об осадках осуцтвует"}
    10 {set precipitation "без осадков"}
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
# PRESSURE in mm. Hg
set pressure_max [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PRESSURE/@max)}]
set pressure_min [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PRESSURE/@min)}]

#TEMPERATURE in C
set temperature_max [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/TEMPERATURE/@max)}]
set temperature_min [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/TEMPERATURE/@min)}]

# WIND part
set wind_max [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/WIND/@max)}]
set wind_min [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/WIND/@min)}]
set wind_direction_xml [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/WIND/@direction)}]
switch -exact -- $wind_direction_xml {
    0 {set wind_direction "северный"}
    1 {set wind_direction "северо-восточный"}
    2 {set wind_direction "восточный"}
    3 {set wind_direction "юго-восточный"}
    4 {set wind_direction "южный"}
    5 {set wind_direction "юго-западный"}
    6 {set wind_direction "западный"}
    7 {set wind_direction "северо-западный"}
}

# RELWET
set relwet_max [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/RELWET/@max)}]
set relwet_min [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/RELWET/@min)}]

# HEAT
set heat_max [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/HEAT/@max)}]
set heat_min [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/HEAT/@min)}]

##puts "Город: $sname $index $latitude $longitude"

puts "Дата: $day $month $year $weekday Время: $hour.00 $tod"
puts "Температура: $temperature_min...$temperature_max C"
puts "Атмосферные явления: $sky $precipitation"
puts "Ветер: $wind_direction, $wind_min...$wind_max м/c"
puts "Влажность: $relwet_min...$relwet_max %"
puts "Комфорт: $heat_min...$heat_max C"
puts "\n"
}



