defmodule ChatServer do
  use GenServer

  # Client API

  @doc """
  Inicia el servidor de chat.
  """
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Permite que un usuario se una al servidor de chat.

  ## Parámetros
  - `username`: Nombre del usuario que se va a unir.
  """
  def join(username) do
    GenServer.cast(__MODULE__, {:join, username})
  end

  @doc """
  Permite que un usuario deje el servidor de chat.

  ## Parámetros
  - `username`: Nombre del usuario que se va a retirar.
  """
  def leave(username) do
    GenServer.cast(__MODULE__, {:leave, username})
  end

  @doc """
  Envía un mensaje a todos los usuarios en el servidor de chat.

  ## Parámetros
  - `message`: Mensaje que se va a enviar.
  """
  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message})
  end

  @doc """
  Devuelve la lista de todos los usuarios en el servidor de chat.
  """
  def get_users do
    GenServer.call(__MODULE__, :get_users)
  end

  # Server Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:join, username}, state) do
    new_state = Map.put(state, username, self())
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:leave, username}, state) do
    new_state = Map.delete(state, username)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:broadcast, message}, state) do
    Enum.each(state, fn {username, _pid} ->
      IO.puts("#{username}: #{message}")
    end)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_users, _from, state) do
    users = Map.keys(state)
    {:reply, users, state}
  end
end

# Iniciar el servidor
# {:ok, _pid} = ChatServer.start_link()

# Unir usuarios
# ChatServer.join("Alice")
# ChatServer.join("Bob")
# ChatServer.join("Tom")
# ChatServer.join("Alexa")

# Enviar un mensaje a todos
# ChatServer.broadcast("Hello, everyone!")

# Ver todos los usuarios en el servidor
# users = ChatServer.get_users()
# IO.inspect(users, label: "Current Users")

# Salir del chat
# ChatServer.leave("Alice")

# Ver todos los usuarios en el servidor después de que Alice se fue
# users = ChatServer.get_users()
# IO.inspect(users, label: "Current Users after Alice leaves")
