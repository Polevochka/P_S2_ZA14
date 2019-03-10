unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

  // Делаем матрицу и её размерность глобальными переменными
  // чтобы они были видны во всех функциях -
  // обработчиков нажатия кнопок
  a: Ar;
  n : integer;

implementation

{$R *.lfm}

{ TForm1 }


// удобно будет создать процедуру вывода матрицы в объект типа TStringGrid
// 'var output :TStringGrid' т.к. мы будем изменять объект output - записывать в него
// Хотя это не обязательно, работает и без, тупо для приличия делаем так
procedure PrintAr(a: Ar; n: integer; var output: TStringGrid);
var
  i,j: integer;
  who: integer; // ширина (Width) и высота (Height) ОДНОЙ(One) ячейки таблицы
                // (название из первых букв англ названий)
  s_x: string; // строковое представление элемента матрицы
begin
  // перед записью чего-то в таблицу output очищаем её
  output.Clean;

  output.RowCount := n;  // Число строк
  output.ColCount := n;  // Количество столбцов   ТАБЛИЦЫ

  // Чтобы обращаться к атрибутам output без точки
  // Например раньше надо было писать
  // 'output.ColCount' , теперь же достаточно просто 'ColCount'
  with output do
  begin

    {Устанавливаем одинаковую размер для всех ячеек, ячейки - КВАДРАТНЫЕ}
    // Пусть вся таблица будет 350 x 350
    // тогда на одну ячейку будет уходить
    who := 350 div n;

    // Нам нужно задать размер каждого столбца и каждой строки
    // так как таблица и матрица КВАДРАТНЫЕ и известна
    // ширина - размер столбца
    // высота - размер строки
    // причом это одно число who
    // то это можно сделать в одном цикле
    for i:= 0 to n -1 do
    begin
      RowHeights[i] := who; // для каждой строки одна и та же высота
      ColWidths[i] := who;   // для каждого столбца одна и та же ширина
    end;

    // устанавливаем общие размеры таблицы
    // То что мы делали выше - это только для ячеек
    // Таблица не будет увеличиваться если увеличить только размер ячейки
    // Если ячейка не влезает в видимую область таблицы,
    // то есть в  размер, что стоит по умолчанию
    // Тогда будут появляться ПОЛОСЫ ПРОКРУТКИ - СКРОЛБАР
    height := 350;
    width := 350;
    // Здесь стоит отметить, что мы в обоих таблицах
    // StringGrid1 и StringGrid2 через инспектор объектов
    // Изменили свойство ScrollBars - поставили ssNone
    // То есть полосы прокрутки просто никогда не будут появляться

    // Теперь заполняем таблицу, элементами из матрицы
    for i:=0 to n-1 do
      for j:=0 to n-1 do
      begin
        // Столбцы и строки у ТАБЛИЦЫ нумеруются с нуля,
        // а в матрице с еденицы
        // поэтому обходим с 0 в циклах
        // и обращаемся к элементам МАТРИЦЫ так a[i+1, j+1]
        // Преобразуем число - елемент матрицы в СТРОКУ
        // Ячейки ТАБЛИЦЫ - это строки
        str(a[i+1, j+1], s_x);
        // Еслибы не with приходилось бы обращаться output.Cells
        // Cells - по сути та же матрица - только нашей таблицы output
        // И строки и столбцы у неё нумеруются с 0 - ЗАПОМНИТЕ
        // Также ВАЖНО помнить, что если обращаться к элементу МАТРИЦЫ
        // То мы пишем сначала номер строки потом столбца : a[i,j](если i,j > 1 конешн)
        // Но в Cells нужно СНАЧАЛА передавать номер СТОЛБЦА, и уже ПОТОМ номер СТРОКИ
        // То есть Cells[j,i] - НЕ опечатка
        Cells[j,i] := s_x;
      end;
  end;
end;

{Считываем матрицу из StringGrid}
// 'var' чтобы изменить переменные передавааемые в функцию
// input: TStringGrid без var т.к. мы только считываем оттуда
procedure ReadAr(var a: Ar; var n: integer; input:TStringGrid);
var i, j: integer;

begin
  // Задаём размерность Матрицы
  // Т.к. матрица квадратная, то её размерность можн задать
  // числом столбцов ТАБЛИЦЫ
  n := input.RowCount;
  // или числом строк ТАБЛИЦЫ
  // n:= input.ColCount;

  // Теперь просто обходя все ячейки ТАБЛИЦЫ
  // Заполняем матрицу
  // здесь для примера мы НЕ ИСПОЛЬЗУЕМ with
  // чтобы показать как ещё можно обращаться к атрибутам input
  for i:=0 to input.RowCount-1 do
      for j:=0 to input.ColCount-1 do
          // Помните в Celss СНАЧАЛА СТОЛБЕЦ, ПОТОМ СТРОКУ
          // Так как ячейка таблицы - ЭТО СТРОКА, а элемент матрицы - ЧИСЛО
          // то строку нужно привести к целому числу
          a[i+1, j+1] := StrToInt(input.Cells[j,i]);

end;

{Нажали 'Ввести матрицу'}
procedure TForm1.Button1Click(Sender: TObject);
begin
    // Получаем размерность матрицы от пользователя
    // InputBox возвращает строку, но ГЛОБАЛЬНАЯ переменная 'n' типа integer
    // поэтому преобразуем возвращаем значение в целое число при помощи StrToInt
    n := StrToInt(InputBox('Размерность матрицы', 'Введите целое число', '5'));

    // Теперь так как УЖЕ ЕСТЬ число строк и столбцов
    // Заполняем матрицу
    NewAr(a, n);

    // выводим матрицу в StringGrid1 - исходная матрица
    PrintAr(a, n, StringGrid1);

end;

{Нажали 'ПО ЧС'}
procedure TForm1.Button2Click(Sender: TObject);
var k: integer;
begin
  // получаем сколько поворотов нужно сделать
  k := StrToInt(InputBox('Количество Поворотов', 'Введите целое число', '1'));

  // Считываем исходную матрицу из StringGrid1
  ReadAr(a, n, StringGrid1);

  // true - истина - крутим ПО ЧС
  KTurnAr(a, n, k, true);

  // выводим изменённую матрицу в StringGrid2
  printAr(a,n, StringGrid2);

end;

{Нажали 'ПРОТИВ ЧС'}
procedure TForm1.Button3Click(Sender: TObject);
var k: integer;
begin
  // получаем сколько поворотов нужно сделать
  k := StrToInt(InputBox('Количество Поворотов', 'Введите целое число', '1'));

  // Считываем исходную матрицу из StringGrid1
  ReadAr(a, n, StringGrid1);

  // false - истина - крутим ПРОТИВ ЧС
  KTurnAr(a, n, k, false);

  // выводим изменённую матрицу в Stringgrid2
  printAr(a,n, StringGrid2);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  close;
end;

end.

