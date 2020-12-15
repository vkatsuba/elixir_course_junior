## Неограниченная рекурсия (Unbounded recursion)

Ограниченная рекурсия (bounded recursion) -- это случай, когда число шагов (итераций) известно.

В случае неограниченной рекурсии (unbounded recursion) мы не можем предсказать число итераций. Например, мы реализуем веб-паука, который скачивает веб-страницу, а затем проходит по всем ссылкам на этой странице. Другой пример -- обход файловой системы по дереву каталогов. 

Давайте реализуем второй пример.

TODO

Иногда мы хотим как-то ограничить число итераций. В нашем случае мы можем ограничить глубину обхода каталогов.

TODO реализация.

Или мы хотим гарантировать, что не попадем в бесконечный цикл. В нашем случае нужно проверять, не является ли каталог символической ссылкой, и если является, то игнорировать его. Это оставим для домашнего задания.