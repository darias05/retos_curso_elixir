defmodule Writer do
  @moduledoc """
  This module provides functions for writing Employee data to a JSON file.

  ## Special Symbols
  - `defmodule`: Defines a new module
  - `@moduledoc`: Provides documentation for the module
  """

  alias Empresa.Employee

  @doc """
  Writes an Employee struct to a JSON file.

  ## Parameters
  - `employee`: An Empresa.Employee struct to be written
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the write operation is successful
  - `{:error, term()}` if an error occurs

  ## Examples
      iex> employee = Empresa.Employee.new("Jane Doe", "Manager")
      iex> Writer.write_employee(employee)
      :ok
  """
  @spec write_employee(Employee.t(), String.t()) :: :ok | {:error, term()}
  def write_employee(%Employee{} = employee, filename \\ "employees.json") do
    employees = read_employees(filename)
    new_id = get_next_id(employees)
    updated_employee = Map.put(employee, :id, new_id)
    updated_employees = [updated_employee | employees]

    json_data = Jason.encode!(updated_employees, pretty: true)
    File.write(filename, json_data)
  end

  # Eliminamos la etiqueta @doc para funciones privadas
  @spec read_employees(String.t()) :: [Employee.t()]
  defp read_employees(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        Jason.decode!(contents, keys: :atoms)
        |> Enum.map(&struct(Employee, &1))
      {:error, :enoent} -> []
    end
  end

  @spec get_next_id([Employee.t()]) :: integer()
  defp get_next_id(employees) do
    employees
    |> Enum.map(& &1.id)
    |> Enum.max(fn -> 0 end)
    |> Kernel.+(1)
  end

  @doc """
  Deletes an employee by ID from the JSON file.

  ## Parameters
  - `id`: Integer, the ID of the employee to delete
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the delete operation is successful
  - `{:error, term()}` if an error occurs

  ## Examples
      iex> Writer.delete_employee(1)
      :ok
  """
  @spec delete_employee(integer(), String.t()) :: :ok | {:error, term()}
  def delete_employee(id, filename \\ "employees.json") do
    employees = read_employees(filename)
    updated_employees = Enum.reject(employees, &(&1.id == id))

    json_data = Jason.encode!(updated_employees, pretty: true)
    File.write(filename, json_data)
  end

  @doc """
  Updates an existing employee in the JSON file.

  ## Parameters
  - `employee`: An Empresa.Employee struct with updated data
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the update operation is successful
  - `{:error, :not_found}` if the employee does not exist
  - `{:error, term()}` if another error occurs

  ## Examples
      iex> employee = %Empresa.Employee{id: 1, name: "Jane Doe", position: "Senior Manager"}
      iex> Writer.update_employee(employee)
      :ok
  """
  @spec update_employee(Employee.t(), String.t()) :: :ok | {:error, term()}
  def update_employee(%Employee{id: id} = employee, filename \\ "employees.json") do
    employees = read_employees(filename)

    case Enum.find_index(employees, &(&1.id == id)) do
      nil -> {:error, :not_found}
      index ->
        updated_employees = List.replace_at(employees, index, employee)
        json_data = Jason.encode!(updated_employees, pretty: true)
        File.write(filename, json_data)
    end
  end
end

# Definimos Reader, Empresa y Employee solo si no están ya definidos
unless Code.ensure_loaded?(Reader) do
  defmodule Reader do
    @moduledoc """
    This module provides functions for reading Employee data from a JSON file.

    ## Special Symbols
    - `defmodule`: Defines a new module
    - `@moduledoc`: Provides documentation for the module
    """

    alias Empresa.Employee

    @doc """
    Reads all employees from the JSON file.

    ## Parameters
    - `filename`: String, the name of the JSON file to read from (optional, default: "employees.json")

    ## Returns
    - List of Employee structs

    ## Examples
        iex> Reader.read_all_employees()
        [%Empresa.Employee{...}, ...]
    """
    @spec read_all_employees(String.t()) :: [Employee.t()]
    def read_all_employees(filename \\ "employees.json") do
      case File.read(filename) do
        {:ok, contents} ->
          Jason.decode!(contents, keys: :atoms)
          |> Enum.map(&struct(Employee, &1))
        {:error, :enoent} -> []
      end
    end

    @doc """
    Reads an employee by their ID from the JSON file.

    ## Parameters
    - `id`: Integer, the ID of the employee to find
    - `filename`: String, the name of the JSON file to read from (optional, default: "employees.json")

    ## Returns
    - `{:ok, Employee.t()}` if the employee is found
    - `{:error, :not_found}` if the employee is not found

    ## Examples
        iex> Reader.read_employee_by_id(1)
        {:ok, %Empresa.Employee{id: 1, ...}}

        iex> Reader.read_employee_by_id(999)
        {:error, :not_found}
    """
    @spec read_employee_by_id(integer(), String.t()) :: {:ok, Employee.t()} | {:error, :not_found}
    def read_employee_by_id(id, filename \\ "employees.json") do
      employees = read_all_employees(filename)

      case Enum.find(employees, &(&1.id == id)) do
        nil -> {:error, :not_found}
        employee -> {:ok, employee}
      end
    end
  end
end

unless Code.ensure_loaded?(Empresa) do
  defmodule Empresa do
    @moduledoc """
    This module contains the Employee struct and related functions.

    ## Special Symbols
    - `defmodule`: Defines a new module
    - `@moduledoc`: Provides documentation for the module
    """

    defmodule Employee do
      @moduledoc """
      Defines the Employee struct with common attributes.

      ## Special Symbols
      - `defmodule`: Defines a nested module
      - `@moduledoc`: Provides documentation for the module
      - `@enforce_keys`: Specifies which keys must be set when creating a new struct
      - `defstruct`: Defines a struct with the specified fields
      - `@type`: Defines a custom type for the struct
      """

      @enforce_keys [:name, :position]
      @derive {Jason.Encoder, only: [:id, :name, :position, :email, :phone, :hire_date, :salary]}
      defstruct [:id, :name, :position, :email, :phone, :hire_date, :salary]

      @type t :: %__MODULE__{
        id: integer() | nil,
        name: String.t(),
        position: String.t(),
        email: String.t() | nil,
        phone: String.t() | nil,
        hire_date: Date.t() | nil,
        salary: float() | nil
      }

      @doc """
      Creates a new Employee struct.

      ## Parameters
      - `name`: String, the employee's name (required)
      - `position`: String, the employee's job position (required)
      - `opts`: Keyword list of optional attributes (optional)

      ## Returns
      - `%Empresa.Employee{}`: A new Employee struct

      ## Examples
          iex> Empresa.Employee.new("John Doe", "Developer")
          %Empresa.Employee{name: "John Doe", position: "Developer"}
      """
      def new(name, position, opts \\ []) do
        struct!(__MODULE__, [name: name, position: position] ++ opts)
      end
    end
  end
end
