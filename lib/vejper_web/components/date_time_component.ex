defmodule VejperWeb.DateTimeComponent do
  use Phoenix.Component
  attr :dt, :any, required: true
  attr :class, :string, default: "self-end font-italic text-[0.7rem]"

  def datetime(assigns) do
    ~H"""
    <time class={@class}>
      <%= date =
        DateTime.from_naive!(@dt, "Europe/Belgrade")
        |> DateTime.to_date()

      time =
        DateTime.from_naive!(@dt, "Europe/Belgrade")
        |> DateTime.to_time()

      transform_date(date) |> transform_time(time) %>
    </time>
    """
  end

  defp transform_date(date) do
    case Date.diff(Date.utc_today(), date) do
      0 ->
        "Danas"

      1 ->
        "Juče"

      2 ->
        "Prekjuče"

      n when n < 11 ->
        "Pre " <> Integer.to_string(n) <> " dana"

      _ ->
        Integer.to_string(date.day) <>
          "." <> Integer.to_string(date.month) <> "." <> Integer.to_string(date.year)
    end
  end

  defp transform_time(date, time) do
    if date == "Danas" do
      case Time.utc_now() |> Time.diff(time, :second) do
        n when n < 60 ->
          "Upravo sada"

        n when n < 1800 ->
          "Pre " <> Integer.to_string(Integer.floor_div(n, 60)) <> " minuta"

        n when n < 2700 ->
          "Pre pola sata"

        n when n < 4500 ->
          "Pre sat vremena"

        n when n < 5400 ->
          "Pre dva sata"

        n when n < 9000 ->
          "Pre tri sata"

        _ ->
          ("Danas u " <> Time.to_string(time))
          |> String.replace(~r/\.[^.]*?$/, "")
          |> String.slice(0..-4)
      end
    else
      (date <> " u " <> Time.to_string(time))
      |> String.replace(~r/\.[^.]*?$/, "")
      |> String.slice(0..-4)
    end
  end
end
