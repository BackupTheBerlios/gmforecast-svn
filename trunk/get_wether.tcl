#!sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec wish "$0" ${1+"$@"}

#�������� �������
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
#TOWN     ���������� � ������ ���������������:
#  index     ���������� ����������� ��� ������
#  sname     �������������� �������� ������
#  latitude     ������ � ����� ��������
# longitude     ������� � ����� ��������
#FORECAST     ���������� � ����� ���������������:
#  day, month, year     ����, �� ������� ��������� ������� � ������ �����
#  hour     ������� �����, �� ������� ��������� �������
#  tod     ����� �����, ��� �������� ��������� �������: 0 - ���� 1 - ����, 2 - ����, 3 - �����
#  weekday     ���� ������, 1 - �����������, 2 - �����������, � �.�.
#  predict     ������������������ �������� � �����
#PHENOMENA      ����������� �������:
#  cloudiness     ���������� �� ���������:  0 - ����, 1- �����������, 2 - �������, 3 - ��������
#  precipitation     ��� �������: 4 - �����, 5 - ������, 6,7 � ����, 8 - �����, 9 - ��� ������, 10 - ��� �������
#  rpower     ������������� �������, ���� ��� ����. 0 - �������� �����/����, 1 - �����/����
#  spower     ����������� �����, ���� ��������������: 0 - �������� �����, 1 - �����
#PRESSURE     ����������� ��������, � ��.��.��.
#TEMPERATURE     ����������� �������, � �������� �������
#WIND     ��������� �����
#  min, max     ����������� � ������������ �������� ������� �������� �����, ��� �������
#  direction      ����������� ����� � ������, 0 - ��������, 1 - ������-���������,  � �.�.
#RELWET     ������������� ��������� �������, � %
#HEAT     ������� - ����������� �������� �� �������� ������� �� ������ ��������, ���������� �� �����

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
    0 {set tod "����"}
    1 {set tod "����"}
    2 {set tod "����"}
    3 {set tod "�����"}
}

# PHENOMENA part
set rpower [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@rpower)}]
set spower [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@spower)}]

set cloudiness [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@cloudiness)}]
switch -exact -- $cloudiness {
    0 {set sky "����"}
    1 {set sky "�����������"}
    2 {set sky "�������"}
    3 {set sky "��������"}
}
set precipitation_xml [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@precipitation)}]
switch -exact -- $precipitation_xml {
    4 {
        if {$rpower == 1} {
        set precipitation "�����"
        } else {
        set precipitation "�������� �����"
        }
    }
    5 {set precipitation "������"}
    6 {
        if {$rpower == 1} {
        set precipitation "����"
        } else {
        set precipitation "�������� ����"
        }
    }
    7 {
        if {$rpower == 1} {
        set precipitation "����"
        } else {
        set precipitation "�������� ����"
        }
    }
    8 {
        if {$rpower == 1} {
        set precipitation "�����"
        } else {
        set precipitation "�������� �����"
        }
    }
    9 {set precipitation "���������� �� ������� ���������"}
    10 {set precipitation "��� �������"}
}

set weekday_xml [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/@weekday)}]
switch -exact -- $weekday_xml {
    1 {set weekday "�����������"}
    2 {set weekday "�����������"}
    3 {set weekday "�������"}
    4 {set weekday "�����"}
    5 {set weekday "�������"}
    6 {set weekday "�������"}
    7 {set weekday "�������"}
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
    0 {set wind_direction "��������"}
    1 {set wind_direction "������-���������"}
    2 {set wind_direction "���������"}
    3 {set wind_direction "���-���������"}
    4 {set wind_direction "�����"}
    5 {set wind_direction "���-��������"}
    6 {set wind_direction "��������"}
    7 {set wind_direction "������-��������"}
}

# RELWET
set relwet_max [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/RELWET/@max)}]
set relwet_min [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/RELWET/@min)}]

# HEAT
set heat_max [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/HEAT/@max)}]
set heat_min [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/HEAT/@min)}]

##puts "�����: $sname $index $latitude $longitude"

#puts "����: $day $month $year $weekday �����: $hour.00 $tod"
#puts "�����������: $temperature_min...$temperature_max C"
#puts "����������� �������: $sky $precipitation"
#puts "�����: $wind_direction, $wind_min...$wind_max �/c"
#puts "���������: $relwet_min...$relwet_max %"
#puts "�������: $heat_min...$heat_max C"
#puts "\n"
wm title . gmForecast
frame .toppy -borderwidth 10
pack .toppy -side top -fill x

button .toppy.refresh -text Hello -command {$log insert end "�����������"}
button .toppy.quit -text Quit -command exit
pack .toppy.refresh -side right


frame .t
set log [text .t.log -width 80 -height 10 -borderwidth 2 -relief raised -setgrid true]
pack .t.log -side left -fill both -expand true
pack .t -side top -fill both -expand true

}


