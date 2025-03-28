// Сервисная функция для получения константы
Функция ВоспроизводитьТекстУведомления() Экспорт
    
	Возврат Константы.ВоспроизводитьТекстУведомления.Получить();
    
КонецФункции

// Процедура отправляет идентификатор источнику push-уведомлений
//
// Параметры:
//  ИдентификаторПодписчикаУведомлений - новый идентификатор
//  ТекстОшибки - параметр для возврата информации об ошибках
//
Процедура ПередатьИдентификаторПодписчикаУведомлений(ИдентификаторПодписчикаУведомлений, ТекстОшибки) Экспорт
	
	СисИнфо = Новый СистемнаяИнформация;
	Справочники.МобильныеУстройства.НовыйИдентификаторПодписчикаУведомлений(Строка(СисИнфо.ИдентификаторКлиента), ИдентификаторПодписчикаУведомлений); 
    
КонецПроцедуры

Процедура ОтправитьУведомление(Уведомление, Пользователь, Проблемы) Экспорт
	
	ИспользоватьPushУведомления = Константы.ИспользоватьPushУведомления.Получить();
	ИспользоватьAPNS = Константы.ИспользоватьAPNS.Получить();
	ИспользоватьFCM = Константы.ИспользоватьFCM.Получить();
	ИспользоватьHPK = Константы.ИспользоватьHPK.Получить();
	ИспользоватьWNS = Константы.ИспользоватьWNS.Получить();
	ИспользоватьСервис = ? (ИспользоватьPushУведомления = Перечисления.PushУведомления.ИспользоватьВспомогательныйСервис, Истина, Ложь);
	Если Не ЗначениеЗаполнено(ИспользоватьPushУведомления)
		ИЛИ ИспользоватьPushУведомления = Перечисления.PushУведомления.НеИспользовать Тогда
		Возврат;
	КонецЕсли;
	Выборка = Справочники.МобильныеУстройства.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений <> Неопределено Тогда
			Если Пользователь = Неопределено ИЛИ Пользователь = Выборка.Владелец Тогда
				Идентификатор = Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений.Получить();
				Если Идентификатор <> Неопределено И
					 ((Идентификатор.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.APNS И (ИспользоватьAPNS = Истина ИЛИ ИспользоватьСервис = Истина))
						ИЛИ (Идентификатор.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.FCM И ИспользоватьFCM = Истина ИЛИ ИспользоватьСервис = Истина)
						ИЛИ (Идентификатор.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.HPK И ИспользоватьHPK = Истина ИЛИ ИспользоватьСервис = Истина)
						ИЛИ (Идентификатор.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.WNS И ИспользоватьWNS = Истина ИЛИ ИспользоватьСервис = Истина)) Тогда
					Уведомление.Получатели.Добавить(Идентификатор);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если Уведомление.Получатели.Количество() > 0 Тогда
		ДанныеАутентификации = "";
		Сертификат = Неопределено;
		Если ИспользоватьСервис = Истина Тогда
			ДанныеАутентификации = Константы.ЛогинСервисаПередачиPushУведомлений.Получить();
		Иначе
			ДанныеАутентификации = Новый Соответствие();
			Если ИспользоватьFCM = Истина Тогда
				ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.FCM] = Константы.КлючCервераОтправителяFCM.Получить();
			КонецЕсли;
			Если ИспользоватьHPK = Истина Тогда
				МаркерДоступа = Константы.МаркерДоступаHPK.Получить();
				Если МаркерДоступа = "" Тогда
					МаркерДоступа = ПолучитьМаркерДоступаHPK();
				КонецЕсли;
				ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.HPK] = МаркерДоступа;
			КонецЕсли;
			Если ИспользоватьAPNS = Истина Тогда
				Сертификат = Константы.СертификатМобильногоПриложенияIOS.Получить();
				Если Сертификат <> Неопределено Тогда
					Сертификат = Сертификат.Получить();
					Если Сертификат <> Неопределено Тогда
						ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.APNS] = Сертификат;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			Если ИспользоватьWNS = Истина Тогда
				МаркерДоступа = Константы.МаркерДоступаWNS.Получить();
				Если МаркерДоступа = "" Тогда
					МаркерДоступа = ПолучитьМаркерДоступаWNS();
				КонецЕсли;
				ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.WNS] = МаркерДоступа;
			КонецЕсли;
		КонецЕсли;
		
		УдаленныеТокены = Новый Массив;
		ОтправкаДоставляемыхУведомлений.Отправить(Уведомление, ДанныеАутентификации, УдаленныеТокены, ИспользоватьСервис, Проблемы);
		НеИспользоватьИдентификаторы(УдаленныеТокены);
		
		Если Проблемы.Количество() > 0 Тогда
			// Проверяем, возможно токен устарел
			ЗапроситьТокенWNS = Ложь;
			ЗапроситьТокенHPK = Ложь;
			Для каждого Проблема Из Проблемы Цикл
				Если Проблема.ТипОшибки = ТипОшибкиОтправкиДоставляемогоУведомления.ОшибкаДанныхАутентификации Тогда
					Для каждого Получатель Из Проблема.Получатели Цикл
						Если Получатель.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.WNS Тогда
							ЗапроситьТокенWNS = Истина;
							Прервать;
						Конецесли;
						Если Получатель.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.HPK Тогда
							ЗапроситьТокенHPK = Истина;
							Прервать;
						Конецесли;
					КонецЦикла;
				Конецесли;
				Если ЗапроситьТокенWNS Тогда
					УдаленныеТокены.Очистить();
					Проблемы.Очистить();
					МаркерДоступа = ПолучитьМаркерДоступаWNS();
					ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.WNS] = МаркерДоступа;
					Прервать;
				Конецесли;
				Если ЗапроситьТокенHPK Тогда
					УдаленныеТокены.Очистить();
					Проблемы.Очистить();
					МаркерДоступа = ПолучитьМаркерДоступаHPK();
					ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.HPK] = МаркерДоступа;
					Прервать;
				Конецесли;
			КонецЦикла;
			Если ЗапроситьТокенWNS ИЛИ ЗапроситьТокенHPK Тогда
				ОтправкаДоставляемыхУведомлений.Отправить(Уведомление, ДанныеАутентификации, УдаленныеТокены, ИспользоватьСервис, Проблемы);
				НеИспользоватьИдентификаторы(УдаленныеТокены);
			Конецесли;
		КонецЕсли;
		
		Если Сертификат <> Неопределено Тогда
			УдаленныеТокены = ОтправкаДоставляемыхУведомлений.ПолучитьИсключенныхПолучателей(Сертификат, ИспользоватьСервис);
			НеИспользоватьИдентификаторы(УдаленныеТокены);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура НеИспользоватьИдентификаторы(Токены)
	
	Если Токены.Количество() > 0 Тогда
		Выборка = Справочники.МобильныеУстройства.Выбрать();
		Пока Выборка.Следующий() Цикл
			Если Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений <> Неопределено Тогда
				Идентификатор = Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений.Получить();
				Если Идентификатор <> Неопределено И Токены.Найти(Идентификатор.ИдентификаторУстройства) <> Неопределено Тогда
		            Узел = Выборка.ПолучитьОбъект();
					Узел.ИдентификаторПодписчикаДоставляемыхУведомлений = Неопределено;
					Узел.Записать();
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьМаркерДоступаWNS()
	
	ИдентификаторПриложения = Константы.ИдентификаторПриложенияWNS.Получить();
	КлючПриложения = Константы.КлючПриложенияWNS.Получить();
	МаркерДоступа = ОтправкаДоставляемыхУведомлений.ПолучитьМаркерДоступа(ИдентификаторПриложения, КлючПриложения);
	Константы.МаркерДоступаWNS.Установить(МаркерДоступа);
	Возврат МаркерДоступа;
	
КонецФункции

Функция ПолучитьМаркерДоступаHPK()
	
	ИдентификаторПриложения = Константы.ИдентификаторПриложенияHPK.Получить();
	КлючПриложения = Константы.КлючПриложенияHPK.Получить();
	МаркерДоступа = ОтправкаДоставляемыхУведомлений.ПолучитьМаркерДоступа(ТипПодписчикаДоставляемыхУведомлений.HPK, ИдентификаторПриложения, КлючПриложения);
	Константы.МаркерДоступаHPK.Установить(МаркерДоступа);
	Возврат МаркерДоступа;
	
КонецФункции

