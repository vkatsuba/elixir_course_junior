# Agent

[Agent](https://hexdocs.pm/elixir/1.12/Agent.html) -- это процесс, который хранит в своей памяти какую-то информацию, которая нужна другим процессам. 

Например, у нас есть чат-сервер, в котором есть список пользователей, находящихся онлайн (подключенных к серверу) в данный момент. 

Эта информация имеет три особенности: 
- она должна храниться столько, сколько живет вся система;
- она нужна многим процессам;
- она постоянно меняется.

В BEAM системах такого рода информацию хранят специальные процессы -- Agent и GenServer. Информация хранится в одном месте и не дублируется, так её проще обновлять. Информация живет столько, сколько живет процесс-владелец. Другие процессы запрашивают информацию у владельца через механизм обмена сообщениями.

Посмотрим, как это работает. 

Мы запускаем Agent и передаём ему функцию, которая должна сформировать начальное состояние. В данном случае это пустой список:
  
```
{:ok, agent_pid} = Agent.start(fn () -> [] end)
```

Затем мы обновляем состояние агента, передавая ему функцию, которая принимает текущее состояние, и возвращает новое. Агент выполняет эту функцию в своём процессе:

```
Agent.update(agent_pid, fn (online_users) -> ["Bob" | online_users] end)
Agent.update(agent_pid, fn (online_users) -> ["Kate" | online_users] end)
```

Мы можем запросить текущее состояние (или его часть), снова передав агенту функцию, которую он выполнит в своём процессе:

```
Agent.get(agent_pid, fn (online_users) -> online_users end)
```

Обновление списка пользователей удобнее обернуть в некое АПИ:

```
add_user = fn(name) ->
  Agent.update(agent_pid, fn (online_users) -> [name | online_users] end)
end

add_user.("John")
```

Запрос списка пользователей тоже удобнее обернуть в АПИ:

```
get_users = fn() ->
  Agent.get(agent_pid, fn (online_users) -> online_users end)
end

get_users.()
```

И дальше с этим можно работать:

```
add_user.("Helen")
add_user.("Bill")
get_users.()
```

Недостаток агента в том, что сторонний код имеет полный доступ к его состоянию. Это легко исправить, если обернуть агент в модуль, и реализовать доступ через АПИ модуля.

Рассмотрим этот подход на примере.

Допустим, наш чат-сервер представляет собой кластер из четырех узлов. Мы хотим распределить онлайн пользователей равномерно между узлами, и для этого применяем шардинг -- делим всех пользователей на 48 групп (шардов). С помощью некой хеширующей функции мы для каждого пользователя вычисляем, к какому шарду он относится. А затем подключаем пользователя к нужному узлу кластера.

Для этого нам нужно знать, за какой диапазон шард отвечает каждый узел. Эту информацию можно хранить в списке:

```
[
  { 0, 11, "Node-1"},
  {12, 23, "Node-2"},
  {24, 35, "Node-3"},
  {36, 47, "Node-4"}
]
```

А список мы будем хранить в агенте. Мы помним, что процесс можно зарегистрировать под определенным именем, чтобы обращаться к нему по имени, а не по pid. Агента тоже можно зарегистрировать таким образом.

```
state = [
  { 0, 11, "Node-1"},
  {12, 23, "Node-2"},
  {24, 35, "Node-3"},
  {36, 47, "Node-4"}
]
Agent.start(fn () -> state end, [name: :sharding_info])
```

Обернем агента в модуль, реализуем АПИ для доступа к информации о шардах, и посмотрим, как это работает:

```
iex(1)> c "10_02_sharding_agent.exs"
[Lesson_10.Task_02_Sharding]
iex(2)> alias Lesson_10.Task_02_Sharding, as: T
Lesson_10.Task_02_Sharding
iex(3)> T.start
:ok
iex(4)> T.find_node(1)
{:ok, "Node-1"}
iex(5)> T.find_node(10)
{:ok, "Node-1"}
iex(6)> T.find_node(12)
{:ok, "Node-2"}
iex(7)> T.find_node(30)
{:ok, "Node-3"}
iex(8)> T.find_node(300)
{:error, :not_found}
```

TODO - добавить АПИ для изменения состояния

TODO - показать работу с агентом из двух разных процессов
  
