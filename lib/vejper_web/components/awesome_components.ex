defmodule VejperWeb.AwesomeComponents do
  use Phoenix.Component
  import VejperWeb.CoreComponents
  import VejperWeb.DateTimeComponent
  alias Phoenix.LiveView.JS
  import VejperWeb.AuthorizationHelpers
  attr :show, :any
  attr :form, :any, required: true
  attr :form_id, :string, required: true
  attr :class, :string, default: "w-full flex items-start"
  attr :placeholder, :string, default: ""
  attr :input_id, :string, required: true

  def awesome_input(assigns) do
    ~H"""
    <%= if @show do %>
      <.form for={@form} id={@form_id} phx-change="validate" phx-submit="save" class={@class}>
        <div class="relative w-full">
          <.input
            id={@input_id}
            placeholder={@placeholder}
            class="py-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2.5  dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            field={@form[:body]}
            type="text"
          />
        </div>
        <.button phx-disable-with="Slanje..." class="py-2 mt-2">Pošalji</.button>
      </.form>
    <% end %>
    """
  end

  attr :patch, :string, required: true
  attr :current_user, :any, required: true

  def awesome_floating_button(assigns) do
    ~H"""
    <.link
      :if={@current_user && @current_user.profile}
      class="fixed bottom-10 right-10"
      patch={@patch}
    >
      <Heroicons.plus class="rounded-full bg-zinc-700 dark:bg-zinc-300 text-white dark:text-black p-4 h-20 w-20" />
    </.link>
    """
  end

  attr :item, :any, required: true
  attr :current_user, :any, required: true
  attr :ad_link, :string, required: true
  attr :user_link, :string, required: true
  attr :id, :string, required: true

  def ad_item(assigns) do
    ~H"""
    <li
      class="shadow-lg flex flex-col items-center w-4/5 h-full md:w-[30rem] p-5 bg-zinc-100 dark:bg-zinc-900 rounded"
      id={@id}
    >
      <div class="w-full flex justify-between items-center">
        <.link navigate={@user_link} class="flex flex-row gap-3 items-center ml-2">
          <img src={@item.user.profile.image.url} class="w-10 h-10 rounded-full" />
          <h4 class="text-[1rem] font-bold"><%= @item.user.profile.username %></h4>
        </.link>
        <.link
          :if={is_owner?(@item, @current_user)}
          class="mx-5"
          phx-click={JS.push("delete", value: %{id: @item.id})}
          data-confirm="Da li ste sigurni?"
        >
          <Heroicons.trash class="w-7 h-7" />
        </.link>
      </div>
      <.link class="flex flex-col justify-around items-center w-[90%] h-[40vh]" navigate={@ad_link}>
        <h2 class="font-bold text-[1.5rem] text-center"><%= @item.title %></h2>
        <img
          :if={is_list(@item.images) && Enum.at(@item.images, 0) != nil}
          src={Enum.at(@item.images, 0).url}
          alt={@item.title}
          class="h-full object-contain"
        />
      </.link>

      <div class="grid grid-cols-3 basis-full my-5 w-full items-center">
        <div class="font-bold text-[1.6rem]"><%= @item.price %>RSD</div>
        <div class="font-bold text-[1.1rem] juctify-self-center text-center">
          <%= @item.city %>
        </div>
        <div class={"font-bold justify-self-end truncate text-elipsis w-[10rem] text-end" <> case @item.state, do: ("Novo" -> " text-[#00ff00]"; "Neupotrebljivo" -> " text-[#ff0000]"; _-> "")}>
          <%= @item.state %>
        </div>
      </div>
      <p class={"my-4 md:pb-5 text-center text-zinc-900 dark:text-zinc-100 w-full"<>if is_list(@item.images) && Enum.at(@item.images, 0) !=nil, do:  " truncate text-elipsis", else: ""}>
        <%= @item.description %>
      </p>
      <.datetime id={@item.id} dt={@item.inserted_at} />
    </li>
    """
  end

  attr :item, :any, required: true
  attr :current_user, :any, required: true
  attr :post_link, :string, required: true
  attr :user_link, :string, required: true
  attr :id, :string, required: true

  def post_item(assigns) do
    ~H"""
    <li
      id={@id}
      class="shadow-lg w-[80%] bg-zinc-50 dark:bg-zinc-900 w-4/5 md:w-[30rem]  rounded items-center flex flex-col justify-around py-3"
    >
      <.link navigate={@user_link} class="self-start flex flex-row gap-3 items-center ml-2">
        <img src={@item.user.profile.image.url} class="w-10 h-10 rounded-full" />
        <h4 class="text-[1rem] font-bold"><%= @item.user.profile.username %></h4>
      </.link>
      <.link
        navigate={@post_link}
        class="items-center flex flex-col justify-around py-3 rounded w-[90%]"
      >
        <h3 class="text-[1.725rem] font-bold"><%= @item.title %></h3>
        <%= case Enum.fetch(@item.images, 0) do %>
          <% {:ok, img} -> %>
            <img src={img.url} alt={img.url} class="w-[80%]" />
            <p class="truncate text-elipsis w-full mt-4 text-zinc-900 dark:text-zinc-100">
              <%= @item.body %>
            </p>
          <% _ -> %>
            <p><%= @item.body %></p>
        <% end %>
        <div class="self-end flex flex-row gap-1 items-center my-2">
          <Heroicons.heart
            solid={
              if @current_user && Enum.find_index(@item.users, &(&1.id == @current_user.id)),
                do: true,
                else: false
            }
            class="h-8 w-8 text-[#ff0000]"
          />
          <span><%= @item.reactions %></span>
        </div>
        <.datetime id={@item.id} dt={@item.inserted_at} />
      </.link>
    </li>
    """
  end

  attr :href, :any, required: true
  slot :inner_block, required: true
  attr :method, :string, default: "get"
  attr :active, :boolean, default: false

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={"hover:bg-zinc-300 dark:hover:bg-zinc-700 p-1 md:p-2 pt-4 rounded-t-md text-lg relative top-[2px]
      hover:border-zinc-500 border-solid hover:border-b-2
      leading-6 text-zinc-900 dark:text-zinc-200 dark:hover:text-zinc-300
      font-semibold hover:text-zinc-700 basis-full text-center" <> if @active, do: " cursor-default hover:bg-zinc-100 dark:hover:bg-zinc-800 border-solid border-b-2 border-brand text-brand hover:text-brand dark:text-brand dark:hover:text-brand hover:border-brand", else: ""}
      method={@method}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
