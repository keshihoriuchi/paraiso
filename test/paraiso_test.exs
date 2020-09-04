defmodule ParaisoTest do
  use ExUnit.Case
  doctest Paraiso

  import Paraiso

  test "example object" do
    email_regex =
      ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

    props = [
      prop(:user_id, :required, {:string, {:regex, ~r/^[a-zA-Z0-9]{1,255}$/}}),
      prop(:name, {:optional, ""}, {:string, {:range, 0, 255}}),
      prop(
        :emails,
        {:optional, []},
        {:array,
         {:object,
          [
            prop(:email_address, :required, {:string, {:regex, email_regex}}),
            prop(:is_primary, :required, :boolean),
            prop(:notification, {:optional, false}, :boolean)
          ]}}
      )
    ]

    ## Success case
    sample = %{
      "user_id" => "keshihoriuchi",
      "name" => "Takeshi Horiuchi",
      "emails" => [
        %{
          "email_address" => "keshihoriuchi@gmail.com",
          "is_primary" => true,
          "notification" => true
        },
        %{
          "email_address" => "keshihoriuchi2@gmail.com",
          "is_primary" => false
        }
      ]
    }

    {:ok, result} = Paraiso.process(sample, props)

    expect = %{
      user_id: "keshihoriuchi",
      name: "Takeshi Horiuchi",
      emails: [
        %{
          email_address: "keshihoriuchi@gmail.com",
          is_primary: true,
          notification: true
        },
        %{
          email_address: "keshihoriuchi2@gmail.com",
          is_primary: false,
          notification: false
        }
      ]
    }

    assert(result === expect)

    ## Failure case
    sample = %{
      "user_id" => "keshihoriuchi",
      "name" => "Takeshi Horiuchi",
      "emails" => [
        %{
          "email_address" => "invalid string",
          "is_primary" => true,
          "notification" => true
        },
        %{
          "email_address" => "keshihoriuchi2@gmail.com",
          "is_primary" => false
        }
      ]
    }

    assert({:error, [:emails, 0, :email_address], :invalid} === Paraiso.process(sample, props))
  end
end
