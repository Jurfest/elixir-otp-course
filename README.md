# Servy

[![Elixir](https://img.shields.io/badge/elixir-%234B275F.svg?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/)

## Description

**My result after complete the course "Developing with Elixir/OTP" by Pragmatic Studio**

## Installation

1. **Clone the repository**:
    ```sh
    git clone https://github.com/jurfest/elixir-otp-course.git
    cd elixir-otp-course
    ```

2. **Install dependencies**:
    ```sh
    mix deps.get
    ```

3. **Compile the project**:
    ```sh
    mix compile
    ```

## Usage

### Running the Application

To start your application:

<!-- ```sh
mix run --no-halt
``` -->
```sh
mix run -e "Servy.HttpServer.start(4000)"
```

## Running Tests

**To run tests:**

```sh
mix test
```

## Interactive Elixir (IEx)

**You can start an IEx session with your project’s dependencies and configuration loaded by running:** 

```sh
iex -S mix
```

## More information about Servy

### Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `servy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:servy, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/servy>.