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

  `:required` or `{:optional, default :: term()}`

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

  ## validator

  ### `:int`

  整数型であるか検証

      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, :int)])
      {:ok, %{a: 1}}
      iex> Paraiso.process(%{"a" => "foo"}, [Paraiso.prop(:a, :required, :int)])
      {:error, :a, :invalid}

  ### `{:int, {:range, min :: integer(), max :: integer()}}`

  min以上max未満の整数型であるか検証

      iex> Paraiso.process(%{"a" => 1}, [Paraiso.prop(:a, :required, {:int, {:range, 0, 100}})])
      {:ok, %{a: 1}}
      iex> Paraiso.process(%{"a" => 101}, [Paraiso.prop(:a, :required, {:int, {:range, 0, 100}})])
      {:error, :a, :invalid}


  ### `{:string, {:regex, Regex.t()}}`

  正規表現にマッチする文字列であるか検証

      iex> Paraiso.process(%{"a" => "abc"}, [Paraiso.prop(:a, :required, {:string, {:regex, ~r/^abc/}})])
      {:ok, %{a: "abc"}}
      iex> Paraiso.process(%{"a" => "def"}, [Paraiso.prop(:a, :required, {:string, {:regex, ~r/^abc/}})])
      {:error, :a, :invalid}

  ### `String.t()`

  文字列リテラルと一致するか検証

      iex> Paraiso.process(%{"a" => "abc"}, [Paraiso.prop(:a, :required, "abc")])
      {:ok, %{a: "abc"}}
      iex> Paraiso.process(%{"a" => "def"}, [Paraiso.prop(:a, :required, "abc")])
      {:error, :a, :invalid}

  ### `{:string_literals, [String.t()]}`

  リスト中のいずれかの文字列リテラルと一致するか検証

      iex> Paraiso.process(%{"a" => "abc"}, [Paraiso.prop(:a, :required, {:string_literals, ["abc", "def"]})])
      {:ok, %{a: "abc"}}
      iex> Paraiso.process(%{"a" => "def"}, [Paraiso.prop(:a, :required, {:string_literals, ["abc", "def"]})])
      {:ok, %{a: "def"}}
      iex> Paraiso.process(%{"a" => "ghi"}, [Paraiso.prop(:a, :required, {:string_literals, ["abc", "def"]})])
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

  ### `{:custom, (value :: term() -> :ok | {:error, reason :: atom()})}`

  関数で検証する。関数は成功なら`:ok`、失敗なら `{:error, <失敗理由> :: atom()}` を返す

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
      {:ok, %{a: 1}}
      {:error, :a, :invalid}

  """
  @spec prop(
          name :: atom(),
          required_or_optional :: :required | {:optional, default :: term()},
          validator ::
            :int
            | {:int, {:range, min :: integer(), max :: integer()}}
            | {:string, {:regex, Regex.t()}}
            | String.t()
            | {:string_literals, [String.t()]}
            | {:object, [prop()]}
            | {:array, validator()}
            | {:custom, (value :: term() -> :ok | {:error, reason :: atom()})}
        ) :: prop()
  def prop(name, req_or_opt, validator) do
    {name, req_or_opt, validator}
  end

  # propの型違反で展開した型で警告を出してほしいので二重定義しているができれば一本化したい
  @typedoc """
  validatorを表す型。`prop/3`の引数validatorと同じ
  """
  @type validator ::
          :int
          | {:int, {:range, min :: integer(), max :: integer()}}
          | {:string, {:regex, Regex.t()}}
          | String.t()
          | {:string_literals, [String.t()]}
          | {:object, [prop()]}
          | {:array, validator()}
          | {:custom, (value :: term() -> :ok | {:error, reason :: atom()})}

  @typedoc """
  `prop/3`で宣言して`process/2`で処理される処理内容を表現した中間オブジェクト
  """
  @opaque prop :: {atom(), :required | {:optional, term()}, term()}

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
  @spec process(map(), [prop()]) :: {:ok, map()} | {:error, atom() | list[atom()], atom()}
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
          :required -> {:halt, {:error, name, :required}}
          {:optional, default} -> {:cont, {:ok, Map.put(acc, name, default)}}
        end
    end
  end

  defp process_validator(name, value, validator, {:ok, acc}) when is_binary(validator) do
    if value == validator do
      {:cont, {:ok, Map.put(acc, name, value)}}
    else
      {:halt, {:error, name, :invalid}}
    end
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

  defp process_validator(name, value, {:string, {:regex, regex}}, {:ok, acc}) do
    if String.match?(value, regex) do
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

  defp process_validator(name, value, {:string_literals, list}, {:ok, acc}) do
    if :lists.member(value, list) do
      {:cont, {:ok, Map.put(acc, name, value)}}
    else
      {:halt, {:error, name, :invalid}}
    end
  end

  defp process_validator(name, value, {:custom, custom_function}, {:ok, acc}) do
    case custom_function.(value) do
      :ok ->
        {:cont, {:ok, Map.put(acc, name, value)}}

      {:error, reason} ->
        {:halt, {:error, name, reason}}

      _ ->
        raise "Custom function must return `:ok` or `{:error, reason}`"
    end
  end
end
