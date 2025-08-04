# Donating.io

**Donating.io** is a free, community-driven online database to help you find and share locations accepting various types of donations.

https://donating.io


This is a work in progress.

---

## Development

### Prerequisites

1. **Install Ruby 3.4.3**

   Make sure you have Ruby 3.4.3 installed (as specified in `.ruby-version`). You can use a Ruby version manager like:
   - [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://rvm.io/)

   ```bash
   # With rbenv
   rbenv install 3.4.3
   rbenv local 3.4.3

   # With RVM
   rvm install 3.4.3
   rvm use 3.4.3
   ```

2. **Install Bundler**

   ```bash
   gem install bundler
   ```

### Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/donating.io.git
   cd donating.io
   ```

2. **Install dependencies**

   ```bash
   bundle install
   ```

3. **Set up the database**

   ```bash
   # Create and migrate the database
   rails db:create
   rails db:migrate

   # Seed the database with initial data such as categories and countries
   rails db:seed
   ```

4. **Start the development server**

   ```bash
   rails server
   ```

   The application will be available at `http://localhost:3000`

### Testing

- **Run tests**:
  ```bash
  rails test
  ```

---

## Contributing

All kinds of contributions are welcome, to get started:

1. Fork this repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Commit your changes (`git commit -m 'Add feature xyz'`)
4. Push to the branch (`git push origin feature/your-feature-name`)
5. Open a Pull Request

Check out the [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License

This project is licensed under the **GNU Affero General Public License v3.0** (AGPL-3.0).

See the [LICENSE](LICENSE) file for more details.
