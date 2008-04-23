#!sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

#�������� �������
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

# ������ ����� ������� � ���������� ��� ��������, ����� ������������� ��� ���, � ����� ������� �������.
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
    0 {set sky "����"}
    1 {set sky "�����������"}
    2 {set sky "�������"}
    3 {set sky "��������"}
}
set precipitation_xml [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/PHENOMENA/@precipitation)}]
switch -exact -- $precipitation_xml {
    4 {set precipitation "�����"}
    5 {set precipitation "������"}
    6 {set precipitation "����"}
    7 {set precipitation "����"}
    8 {set precipitation "�����"}
    9 {set precipitation "��� ������"}
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

puts "����: $day $month $year $weekday �����: $hour"
puts "Temp max: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/TEMPERATURE/@max)}]"
puts "Temp min: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/TEMPERATURE/@min)}]"
puts "����� �����: [$odessa_doc selectNodes {string(/MMWEATHER/REPORT/TOWN/FORECAST[@day=$day][@hour=$hour][@month=$month][@year=$year]/@tod)}]"
puts "����������� �������: $sky $precipitation"

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


