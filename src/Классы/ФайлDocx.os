Перем ПутьКФайлуИсходный Экспорт;
Перем ПутьРаспакованный Экспорт;
Перем ИмяФайлаШаблона Экспорт;
Перем _ИмяФайла; // Имя выходного файла с расширением
Перем _ОбработчикЗаполнения;
Перем _ПарсерХМЛ;

&Характер("Компанейский")
&Прозвище("docx")
&Желудь
Процедура ПриСозданииОбъекта(
		&Пластилин ОбработчикЗаполнения,
		&Пластилин СериализацияДанныхXML
	)
	_ОбработчикЗаполнения = ОбработчикЗаполнения;
	_ПарсерХМЛ = СериализацияДанныхXML;
	//_ИмяФайла = _ОбработчикЗаполнения.НастройкиПодстановки().ИмяВыходногоФайла;
КонецПроцедуры

Процедура ЗаполнитьФайл() Экспорт

	ИмяФайлаДокумента = ОбъединитьПути(ПутьРаспакованный, "word\document.xml");

	//ПроцессорXML = Новый СериализацияДанныхXML();
	ДанныеОбрабатываемогоXML = _ПарсерХМЛ.ПрочитатьИзФайла(ИмяФайлаДокумента);

	ИзмененныйXML = ПодставитьПараметрыВШаблон(ДанныеОбрабатываемогоXML);
	_ПарсерХМЛ.ЗаписатьВФайл(ИзмененныйXML, ИмяФайлаДокумента, Истина);

КонецПроцедуры

Функция ПодставитьПараметрыВШаблон(ДанныеXML)

	Для Каждого НастройкаПодстановки Из _ОбработчикЗаполнения.НастройкиПодстановки() Цикл
		
		Если НастройкаПодстановки["ИмяВыходногоФайла"] <> _ИмяФайла Тогда
			Продолжить;
		Иначе

			// _Элементы - соответствие
			// Значение - структура (ключ и значение["_Элементы"])
			ПрочитатьУзлыДерева(ДанныеXML, 0, НастройкаПодстановки);

			Прервать;
		КонецЕсли;

	КонецЦикла;

	Возврат ДанныеXML;

КонецФункции

Процедура ПрочитатьУзлыДерева(УзелДерева, Уровень, Знач НастройкаПодстановки)

	Если ТипЗнч(УзелДерева) = Тип("Структура") Тогда // переход к следующему уровню дерева
		_Элементы = УзелДерева["_Элементы"];
		ПрочитатьУзлыДерева(_Элементы, Уровень + 1, НастройкаПодстановки);
	КонецЕсли;

	Если ТипЗнч(УзелДерева) = Тип("Соответствие") Тогда
		Для Каждого Элемент Из УзелДерева Цикл
			ТекстСообщения = ОтступДляУровня(Уровень, " ") + Элемент.Ключ;
			// чтение параграфа
			Если Элемент.Ключ = "w:p" Тогда
				ВыполнитьЗаменуПараметровПараграфа(Элемент, НастройкаПодстановки);
			КонецЕсли;
			// // чтение блока текста внутри параграфа
			// Если Элемент.Ключ = "w:r" Тогда
			// 	ТекстСообщения = "Блок текста";
			// КонецЕсли;
			// Если Элемент.Ключ = "w:t" Тогда
			// 	Если Элемент.Значение.Свойство("_Значение") Тогда
			// 		ТекстСообщения = ТекстСообщения + " == " + Элемент.Значение["_Значение"];
			// 	Иначе
			// 		ТекстСообщения = ТекстСообщения + " == " + Элемент.Значение["_ПробельныеСимволы"];
			// 	КонецЕсли;
			// КонецЕсли;
			// Сообщить(ТекстСообщения);
			ПрочитатьУзлыДерева(Элемент.Значение, Уровень + 1, НастройкаПодстановки);
		КонецЦикла;
	КонецЕсли;

	Если ТипЗнч(УзелДерева) = Тип("Массив") Тогда
		Для Каждого Элемент Из УзелДерева Цикл
			ПрочитатьУзлыДерева(Элемент, Уровень + 1, НастройкаПодстановки);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

// Обход всех блоков текста в параграфе и подмена параметров на значения.
Процедура ВыполнитьЗаменуПараметровПараграфа(Параграф, Знач НастройкаПодстановки)

	Если ТипЗнч(Параграф.Значение["_Элементы"]) <> Тип("Массив") Тогда
		Возврат;
	КонецЕсли;

	ВыполнитьЗаменуВСледующемБлоке = Ложь;

	Для каждого БлокПараграфа Из Параграф.Значение["_Элементы"] Цикл

		Для каждого ЭлементБлокаПараграфа Из БлокПараграфа Цикл
			
			Если ЭлементБлокаПараграфа.Ключ = "w:pPr" Тогда
				Продолжить; // Первым элементом коллекции идут свойства, далее - блоки текста
			КонецЕсли;
	
			Для каждого ЭлементБлокаТекста Из ЭлементБлокаПараграфа.Значение["_Элементы"] Цикл
				Если ЭлементБлокаТекста.Ключ = "w:rPr" Тогда
					Продолжить; // свойства блока текста
				КонецЕсли;
				Если Не ЭлементБлокаТекста.Значение.Свойство("_Значение") Тогда
					Продолжить;
				КонецЕсли;
					
				Если ЭлементБлокаТекста.Значение["_Значение"] = "Параметр" Тогда
					ЭлементБлокаТекста.Значение["_Значение"] = "";
					ВыполнитьЗаменуВСледующемБлоке = Истина;
					Продолжить;
				Иначе
					Если ВыполнитьЗаменуВСледующемБлоке Тогда
						Замена = ЭлементБлокаТекста.Значение["_Значение"];
						ЭлементБлокаТекста.Значение["_Значение"] = НастройкаПодстановки[ЭлементБлокаТекста.Значение["_Значение"]];
						ВыполнитьЗаменуВСледующемБлоке = Ложь;
					КонецЕсли;
					
				КонецЕсли;
	
			КонецЦикла;

		КонецЦикла;

	КонецЦикла;

КонецПроцедуры

Функция ОтступДляУровня(Уровень, СимволОтступа)

	Составляющие = Новый Массив();
	Для Индекс = 0 По Уровень Цикл
		Составляющие.Добавить(СимволОтступа);
	КонецЦикла;
	Возврат СтрСоединить(Составляющие, "");

КонецФункции

Процедура УстановитьИмяФайла(Знач ИмяФайла) Экспорт
	_ИмяФайла = ИмяФайла;
КонецПроцедуры

Функция ИмяФайла() Экспорт
	Возврат _ИмяФайла;
КонецФункции

Функция ТипФайла() Экспорт
	Возврат ".docx";
КонецФункции