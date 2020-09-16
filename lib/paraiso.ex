defmodule Paraiso do
  @moduledoc """
    The module of Paraiso
  """

  @doc """
  オブジェクトのname/valueペアに対する、require/optionalおよびバリデーション仕様を宣言する

  ## 引数

  * name: 宣言対象のname
  * required_or_optional: このプロパティは必須かオプションか
  * validator: バリデーション仕様

  ## required_or_optional

  `:required` or `{:optional, default :: term()} or :optional`

  ### `:required`

  必須属性

      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, :int)])
      {:ok, %{a: 1}}
      iex> Paraiso.process(%{"b" => 1}, [Paraiso.prop(:a, :required, :int)])
      {:error, :a, :required}

  ### `{:optional, default :: term()}`

  オプション属性。省略されていた場合defaultが補完される

      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, {:optional, 0}, :int)])
      {:ok, %{a: 1}}
      iex> Paraiso.process(%{"b" => 1}, [Paraiso.prop(:a, {:optional, 0}, :int)])
      {:ok, %{a: 0}}

  ### `:optional`

  オプション属性。省略されていた場合は補完されない

      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :optional, :int)])
      {:ok, %{a: 1}}
      iex> Paraiso.process(%{"b" => 1}, [Paraiso.prop(:a, :optional, :int)])
      {:ok, %{}}

  ## validator

  ### `:boolean`

  trueまたはfalseであるか検証

      iex> Paraiso.process(%{"a" => true}, [Paraiso.prop(:a, :required, :boolean)])
      {:ok, %{a: true}}
      iex> Paraiso.process(%{"a" => false}, [Paraiso.prop(:a, :required, :boolean)])
      {:ok, %{a: false}}
      iex> Paraiso.process(%{"a" => "foo"}, [Paraiso.prop(:a, :required, :boolean)])
      {:error, :a, :invalid}

  ### `nil`

  nilであるか検証

      iex> Paraiso.process(%{"a" => nil}, [Paraiso.prop(:a, :required, nil)])
      {:ok, %{a: nil}}
      iex> Paraiso.process(%{"a" => false}, [Paraiso.prop(:a, :required, nil)])
      {:error, :a, :invalid}

  ### `:int`

  整数型であるか検証

      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, :int)])
      {:ok, %{a: 1}}
      iex> Paraiso.process(%{"a" => "foo"}, [Paraiso.prop(:a, :required, :int)])
      {:error, :a, :invalid}

  ### `{:int, {:range, min :: integer(), max :: integer()}}`

  min以上max以下の整数型であるか検証

      iex> Paraiso.process(%{"a" => 0}, [Paraiso.prop(:a, :required, {:int, {:range, 0, 100}})])
      {:ok, %{a: 0}}
      iex> Paraiso.process(%{"a" => 100}, [Paraiso.prop(:a, :required, {:int, {:range, 0, 100}})])
      {:ok, %{a: 100}}
      iex> Paraiso.process(%{"a" => -1}, [Paraiso.prop(:a, :required, {:int, {:range, 0, 100}})])
      {:error, :a, :invalid}
      iex> Paraiso.process(%{"a" => 101}, [Paraiso.prop(:a, :required, {:int, {:range, 0, 100}})])
      {:error, :a, :invalid}
      iex> Paraiso.process(%{"a" => "foo"}, [Paraiso.prop(:a, :required, {:int, {:range, 0, 100}})])
      {:error, :a, :invalid}

  ### `:string`

  文字列であるか検証

      iex> Paraiso.process(%{"a" => "a"}, [Paraiso.prop(:a, :required, :string)])
      {:ok, %{a: "a"}}
      iex> Paraiso.process(%{"a" => 123}, [Paraiso.prop(:a, :required, :string)])
      {:error, :a, :invalid}

  ### `{:string, {:range, min :: integer(), max :: integer()}}`

  長さmin以上max以下の文字列であるか検証

      iex> Paraiso.process(%{"a" => "a"}, [Paraiso.prop(:a, :required, {:string, {:range, 1, 3}})])
      {:ok, %{a: "a"}}
      iex> Paraiso.process(%{"a" => "abc"}, [Paraiso.prop(:a, :required, {:string, {:range, 1, 3}})])
      {:ok, %{a: "abc"}}
      iex> Paraiso.process(%{"a" => ""}, [Paraiso.prop(:a, :required, {:string, {:range, 1, 3}})])
      {:error, :a, :invalid}
      iex> Paraiso.process(%{"a" => "abcd"}, [Paraiso.prop(:a, :required, {:string, {:range, 1, 3}})])
      {:error, :a, :invalid}
      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, {:string, {:range, 1, 3}})])
      {:error, :a, :invalid}

  ### `{:string, {:regex, Regex.t()}}`

  正規表現にマッチする文字列であるか検証

      iex> Paraiso.process(%{"a" => "abc"}, [Paraiso.prop(:a, :required, {:string, {:regex, ~r/^abc/}})])
      {:ok, %{a: "abc"}}
      iex> Paraiso.process(%{"a" => "def"}, [Paraiso.prop(:a, :required, {:string, {:regex, ~r/^abc/}})])
      {:error, :a, :invalid}
      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, {:string, {:regex, ~r/^abc/}})])
      {:error, :a, :invalid}

  ### `String.t()`

  文字列リテラルと一致するか検証

      iex> Paraiso.process(%{"a" => "abc"}, [Paraiso.prop(:a, :required, "abc")])
      {:ok, %{a: "abc"}}
      iex> Paraiso.process(%{"a" => "def"}, [Paraiso.prop(:a, :required, "abc")])
      {:error, :a, :invalid}
      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, "abc")])
      {:error, :a, :invalid}

  ### `{:string_literals, [String.t()]}`

  リスト中のいずれかの文字列リテラルと一致するか検証

      iex> Paraiso.process(%{"a" => "abc"}, [Paraiso.prop(:a, :required, {:string_literals, ["abc", "def"]})])
      {:ok, %{a: "abc"}}
      iex> Paraiso.process(%{"a" => "def"}, [Paraiso.prop(:a, :required, {:string_literals, ["abc", "def"]})])
      {:ok, %{a: "def"}}
      iex> Paraiso.process(%{"a" => "ghi"}, [Paraiso.prop(:a, :required, {:string_literals, ["abc", "def"]})])
      {:error, :a, :invalid}
      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, {:string_literals, ["abc", "def"]})])
      {:error, :a, :invalid}

  ### `{:object, [prop()]}`

  対象オブジェクトをvalueとした場合に`Paraiso.process(value, [prop()])`に相当する検証をする

  検証に成功した場合: map()が値部分に格納される

  検証に失敗した場合: `{:error, [<エラーが発生した要素までのパス>], reason}` が返る

      iex> Paraiso.process(
      ...>   %{"a" => %{"b" => "c"}},
      ...>   [Paraiso.prop(:a, :required, {:object, [Paraiso.prop(:b, :required, "c")]})]
      ...> )
      {:ok, %{a: %{b: "c"}}}
      iex> Paraiso.process(
      ...>   %{"a" => %{"b" => "d"}},
      ...>   [Paraiso.prop(:a, :required, {:object, [Paraiso.prop(:b, :required, "c")]})]
      ...> )
      {:error, [:a, :b], :invalid}
      iex> Paraiso.process(
      ...>   %{"a" => "b"},
      ...>   [Paraiso.prop(:a, :required, {:object, [Paraiso.prop(:b, :required, "c")]})]
      ...> )
      {:error, :a, :invalid}

  ### `:object`

  オブジェクト型であるか検証

  検証に成功した場合: map()が値部分に格納される(キーはatom()に変換されない)

  検証に失敗した場合: `{:error, [<エラーが発生した要素までのパス>], reason}` が返る

      iex> Paraiso.process(
      ...>   %{"a" => %{"b" => "c"}},
      ...>   [Paraiso.prop(:a, :required, :object)]
      ...> )
      {:ok, %{a: %{"b" => "c"}}}
      iex> Paraiso.process(
      ...>   %{"a" => 1},
      ...>   [Paraiso.prop(:a, :required, :object)]
      ...> )
      {:error, :a, :invalid}

  ### `{:array, validator()}`

  リスト中の要素に対してvalidator()に基づいて検証する

  検証に失敗した場合、 `{:error, [<エラーが発生した要素までのパス>], reason}` が返る

      iex> Paraiso.process(
      ...>   %{"a" => [1, 2, 3]},
      ...>   [Paraiso.prop(:a, :required, {:array, :int})]
      ...> )
      {:ok, %{a: [1, 2, 3]}}
      iex> Paraiso.process(
      ...>   %{"a" => ["foo", 2, 3]},
      ...>   [Paraiso.prop(:a, :required, {:array, :int})]
      ...> )
      {:error, [:a, 0], :invalid}
      iex> Paraiso.process(
      ...>   %{"a" => [%{"b" => 1}, %{"b" => "c"}]},
      ...>   [Paraiso.prop(:a, :required, {:array, {:object, [Paraiso.prop(:b, :required, :int)]}})]
      ...> )
      {:error, [:a, 1, :b], :invalid}
      iex> Paraiso.process(
      ...>   %{"a" => "foo"},
      ...>   [Paraiso.prop(:a, :required, {:array, {:object, [Paraiso.prop(:b, :required, :int)]}})]
      ...> )
      {:error, :a, :invalid}

  ### `{:or, [validator()]}`

  リスト中のいずれかで成功するか検証する

      iex> Paraiso.process(
      ...>   %{"a" => true},
      ...>   [Paraiso.prop(:a, :required, {:or, [:boolean, "foo"]})]
      ...> )
      {:ok, %{a: true}}
      iex> Paraiso.process(
      ...>   %{"a" => "foo"},
      ...>   [Paraiso.prop(:a, :required, {:or, [:boolean, "foo"]})]
      ...> )
      {:ok, %{a: "foo"}}
      iex> Paraiso.process(
      ...>   %{"a" => "bar"},
      ...>   [Paraiso.prop(:a, :required, {:or, [:boolean, "foo"]})]
      ...> )
      {:error, :a, :invalid}

  ### `{:custom, (value :: term() -> :ok | {:error, reason :: atom()})}`

  関数で検証する。関数の仕様は以下
  - 成功なら `:ok` を返す
  - 成功で、バリデーション済みオブジェクトを返したければ `{:ok, <オブジェクト> :: any()}` を返す
  - 失敗なら `{:error, <失敗理由> :: atom()}` を返す
  - 失敗で、失敗したパスを返したければ `{:error, <失敗したパス情報> :: atom() | [atom() | integer()], <失敗理由> :: atom()}` を返す

      iex> Paraiso.process(
      ...>   %{"a" => 1},
      ...>   [
      ...>     Paraiso.prop(
      ...>       :a,
      ...>       :required,
      ...>       {:custom, fn v -> if(v == 1, do: :ok, else: {:error, :invalid}) end}
      ...>     )
      ...>   ]
      ...> )
      {:ok, %{a: 1}}
      iex> Paraiso.process(
      ...>   %{"a" => 2},
      ...>   [
      ...>     Paraiso.prop(
      ...>       :a,
      ...>       :required,
      ...>       {:custom, fn v -> if(v == 1, do: :ok, else: {:error, :invalid}) end}
      ...>     )
      ...>   ]
      ...> )
      {:error, :a, :invalid}
      iex> Paraiso.process(
      ...>   %{"a" => %{"b" => 1}},
      ...>   [
      ...>     Paraiso.prop(
      ...>       :a,
      ...>       :required,
      ...>       {:custom, fn %{"b" => v} -> if(v == 1, do: {:ok, %{b: v}}, else: {:error, :b, :invalid}) end}
      ...>     )
      ...>   ]
      ...> )
      {:ok, %{a: %{b: 1}}}
      iex> Paraiso.process(
      ...>   %{"a" => %{"b" => 2}},
      ...>   [
      ...>     Paraiso.prop(
      ...>       :a,
      ...>       :required,
      ...>       {:custom, fn %{"b" => v} -> if(v == 1, do: {:ok, %{b: v}}, else: {:error, :b, :invalid}) end}
      ...>     )
      ...>   ]
      ...> )
      {:error, [:a, :b], :invalid}
      iex> Paraiso.process(
      ...>   %{"a" => %{"b" => %{"c" => 2}}},
      ...>   [
      ...>     Paraiso.prop(
      ...>       :a,
      ...>       :required,
      ...>       {:custom, fn %{"b" => %{"c" => v}} -> if(v == 1, do: {:ok, %{b: %{c: v}}}, else: {:error, [:b, :c], :invalid}) end}
      ...>     )
      ...>   ]
      ...> )
      {:error, [:a, :b, :c], :invalid}

  """
  @spec prop(
          name :: atom(),
          required_or_optional :: :required | {:optional, default :: term()} | :optional,
          validator ::
            :boolean
            | nil
            | :int
            | {:int, {:range, min :: integer(), max :: integer()}}
            | :string
            | {:string, {:range, min :: integer(), max :: integer()}}
            | {:string, {:regex, Regex.t()}}
            | String.t()
            | {:string_literals, [String.t()]}
            | {:object, [prop()]}
            | :object
            | {:array, validator()}
            | {:or, [validator()]}
            | {:custom,
               (value :: term() ->
                  :ok
                  | {:ok, any()}
                  | {:error, reason :: atom()}
                  | {:error, atom() | [atom() | integer()], atom()})}
        ) :: prop()
  def prop(name, req_or_opt, validator) do
    {name, req_or_opt, validator}
  end

  # propの型違反で展開した型で警告を出してほしいので二重定義しているができれば一本化したい
  @typedoc """
  validatorを表す型。`prop/3`の引数validatorと同じ
  """
  @type validator ::
          :boolean
          | :int
          | nil
          | {:int, {:range, min :: integer(), max :: integer()}}
          | :string
          | {:string, {:range, min :: integer(), max :: integer()}}
          | {:string, {:regex, Regex.t()}}
          | String.t()
          | {:string_literals, [String.t()]}
          | {:object, [prop()]}
          | :object
          | {:array, validator()}
          | {:or, [validator()]}
          | {:custom,
             (value :: term() ->
                :ok
                | {:ok, any()}
                | {:error, reason :: atom()}
                | {:error, atom() | [atom() | integer()], atom()})}

  @typedoc """
  `prop/3`で宣言して`process/2`で処理される処理内容を表現した中間オブジェクト
  """
  @opaque prop :: {atom(), :required | {:optional, term()} | :optional, term()}

  @doc """

  第一引数paramsに対して第二引数propsで宣言されたバリデーションおよびサニタイズを実行する

  ## 返り値

  ### 検証成功の場合

  `{:ok, <サニタイズされた値>}` が返る

  paramsでキーがStringの場合atomに変換される。またpropsに含まれないキーは削除される

      iex> Paraiso.process(%{"a" => "abc", "b" => "cde"}, [Paraiso.prop(:a, :required, "abc")])
      {:ok, %{a: "abc"}}

  ### 検証失敗の場合

  `{:error, <失敗箇所>, <失敗理由>}` が返る

  あるpropで検証失敗した場合その時点で検証処理は打ち切られる。

  """
  @spec process(map(), [prop()]) ::
          {:ok, map()} | {:error, atom() | [atom() | integer()], atom()}
  def process(_params = %{}, []) do
    {:ok, %{}}
  end

  def process(params = %{}, props) do
    Enum.reduce_while(props, {:ok, %{}}, fn prop, acc ->
      process_prop(params, prop, acc)
    end)
  end

  defp process_prop(params, {name, req_or_opt, validator}, {:ok, acc}) do
    str_name = Atom.to_string(name)

    case params do
      %{^str_name => value} ->
        process_validator(name, value, validator, {:ok, acc})

      %{^name => value} ->
        process_validator(name, value, validator, {:ok, acc})

      _not_found ->
        case req_or_opt do
          :required ->
            {:halt, {:error, name, :required}}

          {:optional, default} ->
            {:cont, {:ok, Map.put(acc, name, default)}}

          :optional ->
            {:cont, {:ok, acc}}
        end
    end
  end

  defp process_validator(name, true, :boolean, {:ok, acc}) do
    {:cont, {:ok, Map.put(acc, name, true)}}
  end

  defp process_validator(name, false, :boolean, {:ok, acc}) do
    {:cont, {:ok, Map.put(acc, name, false)}}
  end

  defp process_validator(name, _value, :boolean, _acc) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, nil, nil, {:ok, acc}) do
    {:cont, {:ok, Map.put(acc, name, nil)}}
  end

  defp process_validator(name, _value, nil, _acc) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, :int, {:ok, acc}) when is_integer(value) do
    {:cont, {:ok, Map.put(acc, name, value)}}
  end

  defp process_validator(name, value, :int, _acc) when not is_integer(value) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, {:int, {:range, min, max}}, {:ok, acc})
       when is_integer(value) and min <= value and value <= max do
    {:cont, {:ok, Map.put(acc, name, value)}}
  end

  defp process_validator(name, value, {:int, {:range, _min, _max}}, _acc)
       when is_integer(value) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, {:int, _validator}, _acc) when not is_integer(value) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, :string, {:ok, acc}) when is_binary(value) do
    {:cont, {:ok, Map.put(acc, name, value)}}
  end

  defp process_validator(name, value, :string, _acc) when not is_binary(value) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, {:string, {:range, min, max}}, {:ok, acc})
       when is_binary(value) do
    len = String.length(value)

    if min <= len and len <= max do
      {:cont, {:ok, Map.put(acc, name, value)}}
    else
      {:halt, {:error, name, :invalid}}
    end
  end

  defp process_validator(name, value, {:string, {:range, _min, _max}}, _acc)
       when not is_binary(value) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, {:string, {:regex, regex}}, {:ok, acc})
       when is_binary(value) do
    if String.match?(value, regex) do
      {:cont, {:ok, Map.put(acc, name, value)}}
    else
      {:halt, {:error, name, :invalid}}
    end
  end

  defp process_validator(name, value, {:string, {:regex, _regex}}, _acc)
       when not is_binary(value) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, validator, {:ok, acc}) when is_binary(validator) do
    if value == validator do
      {:cont, {:ok, Map.put(acc, name, value)}}
    else
      {:halt, {:error, name, :invalid}}
    end
  end

  defp process_validator(name, value, {:string_literals, list}, {:ok, acc}) do
    if :lists.member(value, list) do
      {:cont, {:ok, Map.put(acc, name, value)}}
    else
      {:halt, {:error, name, :invalid}}
    end
  end

  defp process_validator(name, %{} = value, {:object, specs}, {:ok, acc}) do
    case process(value, specs) do
      {:ok, params} ->
        {:cont, {:ok, Map.put(acc, name, params)}}

      {:error, error_names, reason} when is_list(error_names) ->
        {:halt, {:error, [name | error_names], reason}}

      {:error, error_names, reason} ->
        {:halt, {:error, [name, error_names], reason}}
    end
  end

  defp process_validator(name, _value, {:object, _specs}, _acc) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, %{} = value, :object, {:ok, acc}) do
    {:cont, {:ok, Map.put(acc, name, value)}}
  end

  defp process_validator(name, _value, :object, _acc) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, {:array, validator}, {:ok, acc}) when is_list(value) do
    result =
      Enum.reduce_while(value, {[], 0}, fn inner_value, {acc_list, i} ->
        case process_validator(:elem, inner_value, validator, {:ok, %{}}) do
          {:cont, {:ok, %{elem: validated_inner_value}}} ->
            {:cont, {acc_list ++ [validated_inner_value], i + 1}}

          {:halt, {:error, [:elem | tail] = _error_names, reason}} ->
            {:halt, {:error, [name, i] ++ tail, reason}}

          {:halt, {:error, :elem, reason}} ->
            {:halt, {:error, [name, i], reason}}
        end
      end)

    case result do
      {:error, error_names, reason} ->
        {:halt, {:error, error_names, reason}}

      {array, _counter} ->
        {:cont, {:ok, Map.put(acc, name, array)}}
    end
  end

  defp process_validator(name, _value, {:array, _validator}, _acc) do
    {:halt, {:error, name, :invalid}}
  end

  defp process_validator(name, value, {:or, validators}, {:ok, acc}) do
    result =
      Enum.any?(validators, fn validator ->
        case process_validator(:elem, value, validator, {:ok, %{}}) do
          {:cont, {:ok, _result}} ->
            true

          _else ->
            false
        end
      end)

    if result do
      {:cont, {:ok, Map.put(acc, name, value)}}
    else
      {:halt, {:error, name, :invalid}}
    end
  end

  defp process_validator(name, value, {:custom, custom_function}, {:ok, acc}) do
    case custom_function.(value) do
      :ok ->
        {:cont, {:ok, Map.put(acc, name, value)}}

      {:ok, value} ->
        {:cont, {:ok, Map.put(acc, name, value)}}

      {:error, reason} ->
        {:halt, {:error, name, reason}}

      {:error, path, reason} when is_list(path) ->
        {:halt, {:error, [name | path], reason}}

      {:error, path, reason} ->
        {:halt, {:error, [name, path], reason}}

      _ ->
        raise "Custom function must return `:ok` or `{:error, reason}`"
    end
  end
end
