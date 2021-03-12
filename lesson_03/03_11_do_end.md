# do-end block

Вы уже заметили, что в Элисир нет фигурных скобок для обозначения границ блоков кода. Вместо них используются ключевые слова **do..end**, как в языке Ruby.

Эти ключевые слова являются макросом :)

Вернемся к конструкции **if**:
```
c = if a > b do
  a
else
  b
end
```

Это макрос, который разворачивается вот в такой код:
```
if(condition, [{:do, code_block_1}, {:else, code_block_2}])
```

Для примера выше получается так:
```
iex(11)> c = if((a > b), [{:do, a}, {:else, b}])
10
```

Макрос принимает два аргумента: предикат, и список из двух кортежей. Первый кортеж содержит ключ **:do** и блок кода, который нужно выполнить, когда предикат возвращает true. Второй кортеж содержит ключ **:else** и второй блок кода.

Так выглядит код в "сыром виде". К нему можно последовательно применить несколько уровней синтаксического сахара. 

Во-первых, если ключи являются атомами, то список пар можно писать в таком виде:
```
iex(11)> c = if((a > b), [do: a, else: b])
10
```
Во-вторых, когда список пар (keyword list) передается в функцию или в макрос, то квадратные скобки можно убрать:
```
iex(13)> c = if(a > b, do: a, else: b)    
10
```
Ну и в случае макроса круглые скобки тоже можно убрать:
```
iex(14)> c = if a > b, do: a, else: b 
10
```


## do: form

Мы получили конструкцию, которая называется **do: form**. Она может применяться везде, где есть **do..end**, вместо **do..end**.

Было:
```
  def gcd(a, b) do
    case rem(a, b) do
      0 -> b
      c -> gcd(b, c)
    end
  end
```

Стало:
```
  def gcd(a, b), do: (
    case rem(a, b), do: (
      0 -> b
      c -> gcd(b, c)
    )
  )
```

Но принято применять **do: form** тогда, когда блок кода представлен одной строкой:
```
  def sk_not(true), do: false
  def sk_not(false), do: true
  def sk_not(nil), do: nil

  def sk_and(false, _), do: false
  def sk_and(nil, false), do: false
  def sk_and(nil, _), do: nil
  def sk_and(true, second_arg), do: second_arg

  def sk_or(true, _), do: true
  def sk_or(nil, true), do: true
  def sk_or(nil, _), do: nil
  def sk_or(false, second_arg), do: second_arg
``` 
