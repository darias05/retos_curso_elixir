defmodule Library do
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def remove_book(library, isbn) do
    Enum.reject(library, &(&1.isbn == isbn))
  end

  def remove_user(users, user_id) do
    Enum.reject(users, &(&1.id == user_id))
  end

  def list_books(library) do
    library
  end

  def list_users(users) do
    users
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def run do
    loop([], [])
  end

  defp loop(library, users) do
    IO.puts("""
    Selecciona una opción:
    1. Agregar libro
    2. Listar libros
    3. Eliminar libro
    4. Agregar usuario
    5. Listar usuarios
    6. Eliminar usuario
    7. Prestar libro
    8. Devolver libro
    9. Libros prestados por usuario
    10. Salir
    """)

    option = IO.gets("> ") |> String.trim() |> String.to_integer()
    case option do
      1 ->
        IO.puts("Ingrese el título del libro:")
        title = IO.gets("> ") |> String.trim()
        IO.puts("Ingrese el autor del libro:")
        author = IO.gets("> ") |> String.trim()
        IO.puts("Ingrese el ISBN del libro:")
        isbn = IO.gets("> ") |> String.trim()
        book = %Book{title: title, author: author, isbn: isbn}
        library = add_book(library, book)
        loop(library, users)

      2 ->
        IO.puts("Libros en la biblioteca:")
        Enum.each(list_books(library), fn book ->
          IO.puts("Título: #{book.title}, Autor: #{book.author}, ISBN: #{book.isbn}, Disponible: #{book.available}")
        end)
        loop(library, users)

      3 ->
        IO.puts("Ingrese el ISBN del libro a eliminar:")
        isbn = IO.gets("> ") |> String.trim()
        library = remove_book(library, isbn)
        loop(library, users)

      4 ->
        IO.puts("Ingrese el nombre del usuario:")
        name = IO.gets("> ") |> String.trim()
        IO.puts("Ingrese el ID del usuario:")
        id = IO.gets("> ") |> String.trim()
        user = %User{name: name, id: id}
        users = add_user(users, user)
        loop(library, users)

      5 ->
        IO.puts("Usuarios en la biblioteca:")
        Enum.each(list_users(users), fn user ->
          IO.puts("Nombre: #{user.name}, ID: #{user.id}")
        end)
        loop(library, users)

      6 ->
        IO.puts("Ingrese el ID del usuario a eliminar:")
        id = IO.gets("> ") |> String.trim()
        users = remove_user(users, id)
        loop(library, users)

      7 ->
        IO.puts("Ingrese el ID del usuario:")
        user_id = IO.gets("> ") |> String.trim()
        IO.puts("Ingrese el ISBN del libro a prestar:")
        isbn = IO.gets("> ") |> String.trim()
        case borrow_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            library = updated_library
            users = updated_users
            IO.puts("Libro prestado exitosamente.")
          {:error, reason} ->
            IO.puts("Error: #{reason}")
        end
        loop(library, users)

      8 ->
        IO.puts("Ingrese el ID del usuario:")
        user_id = IO.gets("> ") |> String.trim()
        IO.puts("Ingrese el ISBN del libro a devolver:")
        isbn = IO.gets("> ") |> String.trim()
        case return_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            library = updated_library
            users = updated_users
            IO.puts("Libro devuelto exitosamente.")
          {:error, reason} ->
            IO.puts("Error: #{reason}")
        end
        loop(library, users)

      9 ->
        IO.puts("Ingrese el ID del usuario:")
        user_id = IO.gets("> ") |> String.trim()
        borrowed_books = books_borrowed_by_user(users, user_id)
        if borrowed_books == [] do
          IO.puts("No hay libros prestados por este usuario.")
        else
          IO.puts("Libros prestados por el usuario #{user_id}:")
          Enum.each(borrowed_books, fn book ->
            IO.puts("Título: #{book.title}, Autor: #{book.author}, ISBN: #{book.isbn}")
          end)
        end
        loop(library, users)

      10 ->
        IO.puts("Gracias por usar la biblioteca.")

      _ ->
        IO.puts("Opción no válida. Inténtalo de nuevo.")
        loop(library, users)
    end
  end
end
