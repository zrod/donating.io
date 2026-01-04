# Donating.io

**Donating.io** is a free, community-driven online database to help you find and share locations accepting various types of donations.

https://donating.io

Work in progress.

---
## Development

### Dependencies

1. **Ruby 3.4+**
2. Ruby on Rails 8+
3. SQLite

### Setup

1. **Clone the repository**

```bash
git clone ssh://git@codeberg.org/zrod/donating.io.git
cd donating.io
```

2. **Install dependencies**

```bash
bundle install
```

3. **Set up the database**

```bash
rails db:setup
```

4. **Start the development server and Solid Queue**

```bash
rails server
rails solid_queue:start
```

The application will be accessible at `http://localhost:3000`

### Extras

Generate some dummy places: `rails places:generate` (optional arg for a number of places to generate: `... places:generate\[30\]`)

### Testing

This project uses Minitest. To run tests, execute the following:

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
