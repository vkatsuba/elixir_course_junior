defmodule HOF do

  def test_data() do
    # {:user, id, name, age}
    [
      {:user, 1, "Bob", 23},
      {:user, 2, "Helen", 20},
      {:user, 3, "Bill", 15},
      {:user, 4, "Kate", 14}
    ]
  end


  def get_average_age(users) do
    collect_stat = fn({:user, _id, _name, age}, {total_users, total_age}) ->
      {total_users + 1, total_age + age}
    end
    {total_users, total_age} = Enum.reduce(users, {0, 0}, collect_stat)
    total_age / total_users
  end


  def filter_by_age(users, max_age) do
    Enum.filter(users, fn({:user, _, _, age}) -> age < max_age end)
  end


  def split_by_age(users) do
    splitter = fn ({:user, _id, _name, age} = user, {adults, children}) ->
      if age > 16 do
        {[user | adults], children}
      else
        {adults, [user | children]}
      end
    end
    Enum.reduce(users, {[], []}, splitter)
  end


  def split_by_age(users, age) do
    splitter = fn({:user, _id, _name, user_age} = user, {older, younger}) ->
      if user_age > age do
        {[user | older], younger}
      else
        {older, [user | younger]}
      end
    end
    Enum.reduce(users, {[], []}, splitter)
  end


  def get_longest_name_user(users) do
    [first | rest] = users
    reducer = fn(user, longest_name_user) ->
      {:user, _, name, _} = user
      {:user, _, longest_name, _} = longest_name_user
      if String.length(longest_name) < String.length(name), do: user, else: longest_name_user
    end
    Enum.reduce(rest, first, reducer)
  end


  def get_oldest_user(users) do
    reducer = fn(user, oldest_user) ->
      {:user, _, _, age} = user
      {:user, _, _, oldest_age} = oldest_user
      if oldest_age < age, do: user, else: oldest_user
    end
    Enum.reduce(users, reducer)
  end

  @spec sort_by(list(), :id | :name | :age) :: list()
  def sort_by(users, compare_type) do
    comparator = case compare_type do
                   :id -> &compare_by_id/2
                   :name -> &compare_by_name/2
                   :age -> &compare_by_age/2
                 end
    Enum.sort(users, comparator)
  end

  def compare_by_id(user1, user2) do
      {:user, id1, _, _} = user1
      {:user, id2, _, _} = user2
      id1 < id2
  end

  def compare_by_name(user1, user2) do
      {:user, _, name1, _} = user1
      {:user, _, name2, _} = user2
      name1 < name2
  end

  def compare_by_age(user1, user2) do
      {:user, _, _, age1} = user1
      {:user, _, _, age2} = user2
      age1 < age2
  end

  def group_users(users) do
    grouper = fn({:user, _, _, age}) ->
      cond do
        age <= 14 -> :child
        age > 14 and age <= 17 -> :teen
        age > 17 -> :adult
      end
    end
    Enum.group_by(users, grouper)
  end

end
