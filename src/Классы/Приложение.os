Перем _Настройки;            // Настройки приложения
Перем _ОбработчикЗаполнения; // Желудь для работы с файлами

&Рогатка
Процедура ПриСозданииОбъекта(
        &Пластилин Настройки,
        &Пластилин ОбработчикЗаполнения)

    _Настройки = Настройки;
    _ОбработчикЗаполнения = ОбработчикЗаполнения;

КонецПроцедуры

Процедура ПриЗапускеПриложения() Экспорт
КонецПроцедуры

Процедура Запустить() Экспорт
    
    _ОбработчикЗаполнения.ПрочитатьНастройкиПодстановки();
    _ОбработчикЗаполнения.СоздатьЗаготовкиФайловИзШаблонов();
    _ОбработчикЗаполнения.ЗаполнитьФайлы();
    _ОбработчикЗаполнения.СохранитьВВыходнойКаталог();

    ВременныйКаталог = ОбъединитьПути(ТекущийКаталог(), _Настройки.КаталогВременныхФайлов());
    УдалитьФайлы(ВременныйКаталог, "*.*");

КонецПроцедуры

Функция Настройки() Экспорт
    Возврат _Настройки;
КонецФункции