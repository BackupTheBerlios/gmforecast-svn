#!sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

#�������� �������
#TOWN 	���������� � ������ ���������������:
#  index 	���������� ����������� ��� ������
#  sname 	�������������� �������� ������
#  latitude 	������ � ����� ��������
# longitude 	������� � ����� ��������
#FORECAST 	���������� � ����� ���������������:
#  day, month, year 	����, �� ������� ��������� ������� � ������ �����
#  hour 	������� �����, �� ������� ��������� �������
#  tod 	����� �����, ��� �������� ��������� �������: 0 - ���� 1 - ����, 2 - ����, 3 - �����
#  weekday 	���� ������, 1 - �����������, 2 - �����������, � �.�.
#  predict 	������������������ �������� � �����
#PHENOMENA  	����������� �������:
#  cloudiness 	���������� �� ���������:  0 - ����, 1- �����������, 2 - �������, 3 - ��������
#  precipitation 	��� �������: 4 - �����, 5 - ������, 6,7 � ����, 8 - �����, 9 - ��� ������, 10 - ��� �������
#  rpower 	������������� �������, ���� ��� ����. 0 - �������� �����/����, 1 - �����/����
#  spower 	����������� �����, ���� ��������������: 0 - �������� �����, 1 - �����
#PRESSURE 	����������� ��������, � ��.��.��.
#TEMPERATURE 	����������� �������, � �������� �������
#WIND 	��������� �����
#  min, max 	����������� � ������������ �������� ������� �������� �����, ��� �������
#  direction  	����������� ����� � ������, 0 - ��������, 1 - ������-���������,  � �.�.
#RELWET 	������������� ��������� �������, � %
#HEAT 	������� - ����������� ������� �� �������� ������� �� ������ ��������, ���������� �� �����

package require tdom
package require http

# ������ ����� ������� � ���������� ��� ��������, ����� ������������� ��� ���, � ����� ������� �������.
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