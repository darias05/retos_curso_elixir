defmodule ChatServer do
  @moduledoc """
  Módulo que representa un servidor de chat que maneja usuarios y mensajes.
  """

  @doc """
  Inicia el servidor de chat.
  """
  def start do
    spawn(fn -> loop(%{}) end)
  end

  @doc """
  Permite que un usuario se una al servidor de chat.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.
  - `user_name`: Nombre del usuario que se va a unir.
  """
  def join(server_pid, user_name) do
    send(server_pid, {:join, user_name, self()})
  end

  @doc """
  Envía un mensaje de un usuario a todos los demás en el servidor de chat.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.
  - `user_name`: Nombre del usuario que envía el mensaje.
  - `message`: Contenido del mensaje.
  """
  def send_message(server_pid, user_name, message) do
    send(server_pid, {:message, user_name, message})
  end

  @doc """
  Solicita la lista de usuarios en el servidor de chat.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.

  ## Retorno
  - Devuelve la lista de usuarios conectados.
  """
  def users(server_pid) do
    send(server_pid, {:users, self()})

    receive do
      {:response, users} -> users
    end
  end

  @doc false
  defp loop(state) do
    new_state =
      receive do
        {:join, user_name, user_pid} ->
          send(user_pid, {:joined, user_name})
          Map.put(state, user_name, user_pid)

        {:message, user_name, message} ->
          broadcast_message(state, user_name, message)
          state

        {:users, caller_pid} ->
          send(caller_pid, {:response, Map.keys(state)})
          state

        _ ->
          IO.puts("Invalid Message")
          state
      end

    loop(new_state)
  end

  defp broadcast_message(state, user_name, message) do
    Enum.each(state, fn {_, pid} ->
      send(pid, {:new_message, user_name, message})
    end)
  end
end

defmodule User do
  @moduledoc """
  Módulo que representa a un usuario en el chat.
  """

  @doc """
  Inicia un proceso de usuario.

  ## Parámetros
  - `name`: Nombre del usuario.
  - `server_pid`: PID del proceso del servidor de chat.
  """
  def start(name, server_pid) do
    spawn(fn -> loop(name, server_pid) end)
  end

  @doc false
  defp loop(name, server_pid) do
    receive do
      {:joined, user_name} ->
        IO.puts("#{user_name} has joined the chat!")
        loop(name, server_pid)

      {:new_message, sender_name, message} ->
        IO.puts("#{sender_name} says: #{message}")
        loop(name, server_pid)

      _ ->
        IO.puts("Invalid Message")
        loop(name, server_pid)
    end
  end
end

# Ejemplo de uso
# server_pid = ChatServer.start()

# user1 = User.start("Alice", server_pid)
# user2 = User.start("Bob", server_pid)

# ChatServer.users(server_pid)

# ChatServer.join(server_pid, "Alice")
# ChatServer.join(server_pid, "Bob")

# ChatServer.send_message(server_pid, "Alice", "Hello, Bob!")
# ChatServer.send_message(server_pid, "Bob", "Hi, Alice!")
