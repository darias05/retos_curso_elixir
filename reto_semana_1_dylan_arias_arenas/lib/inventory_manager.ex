defmodule InventoryManager do
  @moduledoc """
  Módulo para gestionar el inventario de productos.
  """

  @type product :: %{
          id: integer,
          name: String.t(),
          price: Decimal.t(),
          stock: integer
        }
  @type cart_item :: {integer, integer}
  @type inventory :: [product]
  @type cart :: [cart_item]

  @doc """
  Agrega un nuevo producto al inventario.
  """
  def add_product(inventory, name, price, stock) do
    id = Enum.count(inventory) + 1
    product = %{id: id, name: name, price: Decimal.new(price), stock: stock}
    [product | inventory]
  end

  @doc """
  Muestra todos los productos del inventario.
  """
  def list_products(inventory) do
    Enum.each(inventory, fn product ->
      IO.puts("ID: #{product.id} | Name: #{product.name} | Price: #{product.price} | Stock: #{product.stock}")
    end)
  end

  @doc """
  Aumenta el stock de un producto existente.
  """
  def increase_stock(inventory, id, quantity) do
    Enum.map(inventory, fn product ->
      if product.id == id do
        %{product | stock: product.stock + quantity}
      else
        product
      end
    end)
  end

  @doc """
  Reduce el stock de un producto y lo agrega al carrito de compras.
  """
  def sell_product(inventory, cart, id, quantity) do
    {updated_inventory, updated_cart} = Enum.reduce(inventory, {[], cart}, fn product, {inv_acc, cart_acc} ->
      process_product(product, inv_acc, cart_acc, id, quantity)
    end)
    {Enum.reverse(updated_inventory), updated_cart}
  end

  defp process_product(product, inv_acc, cart_acc, id, quantity) do
    if product.id == id do
      update_inventory_and_cart(product, inv_acc, cart_acc, quantity)
    else
      {[product | inv_acc], cart_acc}
    end
  end

  defp update_inventory_and_cart(product, inv_acc, cart_acc, quantity) do
    if product.stock >= quantity do
      new_product = %{product | stock: product.stock - quantity}
      new_cart_item = {product.id, quantity}
      {[new_product | inv_acc], [new_cart_item | cart_acc]}
    else
      IO.puts("No hay suficiente stock para el producto: #{product.name}")
      {[product | inv_acc], cart_acc}
    end
  end


  @doc """
  Muestra los productos en el carrito de compras con sus cantidades y el costo total.
  """
  def view_cart(cart, inventory) do
    total = Enum.reduce(cart, Decimal.new(0), fn {id, quantity}, acc ->
      product = Enum.find(inventory, &(&1.id == id))
      cost = Decimal.mult(product.price, Decimal.new(quantity))
      IO.puts("Product: #{product.name} | Quantity: #{quantity} | Cost: #{cost}")
      Decimal.add(acc, cost)
    end)
    IO.puts("Total Cost: #{total}")
  end

  @doc """
  Realiza el cobro de los productos en el carrito y vacía el carrito.
  """
  def checkout(cart) do
    IO.puts("Checkout completed. Total items: #{Enum.count(cart)}")
    []
  end

  @doc """
  Ejecuta el bucle de interacción con el usuario.
  """
  def run do
    loop([], [])
  end

  defp loop(inventory, cart) do
    IO.puts("""
    Selecciona una opción:
    1. Agregar producto
    2. Listar productos
    3. Aumentar stock
    4. Vender producto
    5. Ver carrito
    6. Pagar
    7. Salir
    """)

    option = IO.gets("> ") |> String.trim() |> String.to_integer()
    case option do
      1 ->
        IO.puts("Ingrese el nombre del producto:")
        name = IO.gets("> ") |> String.trim()
        IO.puts("Ingrese el precio del producto:")
        price = IO.gets("> ") |> String.trim()
        IO.puts("Ingrese el stock del producto:")
        stock = IO.gets("> ") |> String.trim() |> String.to_integer()
        inventory = add_product(inventory, name, price, stock)
        loop(inventory, cart)

      2 ->
        list_products(inventory)
        loop(inventory, cart)

      3 ->
        IO.puts("Ingrese el ID del producto:")
        id = IO.gets("> ") |> String.trim() |> String.to_integer()
        IO.puts("Ingrese la cantidad a aumentar:")
        quantity = IO.gets("> ") |> String.trim() |> String.to_integer()
        inventory = increase_stock(inventory, id, quantity)
        loop(inventory, cart)

      4 ->
        IO.puts("Ingrese el ID del producto:")
        id = IO.gets("> ") |> String.trim() |> String.to_integer()
        IO.puts("Ingrese la cantidad a vender:")
        quantity = IO.gets("> ") |> String.trim() |> String.to_integer()
        {inventory, cart} = sell_product(inventory, cart, id, quantity)
        loop(inventory, cart)

      5 ->
        view_cart(cart, inventory)
        loop(inventory, cart)

      6 ->
        cart = checkout(cart)
        loop(inventory, cart)

      7 ->
        IO.puts("Gracias por usar el gestor de inventario.")

      _ ->
        IO.puts("Opción no válida. Inténtalo de nuevo.")
        loop(inventory, cart)
    end
  end
end
