
# Shop - E-Commerce Application

An e-commerce platform built with Ruby on Rails where users can create accounts, list products for sale, and manage a shopping cart.

## Project Overview

This e-commerce application allows users to:
* Create and manage user accounts
* Create, edit, and delete product listings
* Add products to a shopping cart
* Manage shopping cart contents
* Browse products by various criteria

## Technical Requirements

* Ruby 3.0.0
* Rails 6.1.3
* Node.js 10.17.0+
* Yarn 1.x+
* Mpesa Developer Account

## Environment Setup

1. Create a `.env` file in the root directory:
   ```bash
   touch .env
   ```

2. Add the following environment variables to `.env`:
   ```bash
   # Database Configuration(optional)
   DATABASE_USERNAME=your_username
   DATABASE_PASSWORD=your_password

   # Mpesa API Credentials
   MPESA_CONSUMER_KEY=your_consumer_key
   MPESA_CONSUMER_SECRET=your_consumer_secret
   MPESA_PASSKEY=your_passkey
   MPESA_SHORTCODE=your_shortcode
   MPESA_CALLBACK_URL=your_callback_url

   # Rails Secret Key
   RAILS_MASTER_KEY=your_master_key
   ```

## Mpesa Integration Setup

1. Create a Safaricom Developer Account:
   * Visit [Safaricom Developer Portal](https://developer.safaricom.co.ke/)
   * Sign up for an account
   * Create a new app to get your credentials

2. Configure Mpesa Credentials:
   * Add your Mpesa credentials to `.env` file
   * Ensure your callback URL is accessible (use ngrok for local development)

3. Test Mpesa Integration:
   ```bash
   rails mpesa:test_connection
   ```

## Installation

1. Clone the repository:
   ```markdown
   git clone https://github.com/Vincent-Omondi/shop.git
   cd shop
   ```

2. Install dependencies:
   ```markdown
   bundle install
   bundle update
   ```

3. Set up the database:
   ```markdown
   rails db:migrate
   rails db:seed
   ```

4. Start the Rails server:
   ```markdown
   rails s
   ```

Visit `http://127.0.0.1:3000` to see the application running.

## Core Features

### User Authentication
* User registration and login using Devise
* Profile management
* Secure password handling

### Product Management
* Create product listings with:
  * Title
  * Price
  * Model
  * Description
  * Brand
  * Color
  * Condition
  * Images

### Shopping Cart
* Add/remove items
* Update quantities
* View total price
* Empty cart functionality
* Cart persistence across sessions

## Project Structure

Key components:
* `app/controllers/registrations_controller.rb` - Handles user registration
* `app/helpers/products_helper.rb` - Product display logic
* `app/models/concerns/current_cart.rb` - Shopping cart functionality
* `app/models/cart.rb` - Cart model implementation

## Development

### Running the Development Server
```markdown
rails s
```

### Common Rails Commands
```markdown
rails g scaffold Product # Generate product model and views
rails g controller store index # Generate store controller
rails generate uploader Image # Generate image uploader
rails db:migrate # Run database migrations
```

### Setting Up Local Environment

1. Install ngrok for Mpesa callback URL:
   ```bash
   brew install ngrok # For macOS
   # or download from ngrok.com for other OS
   ```

2. Start ngrok:
   ```bash
   ngrok http 3000
   ```

3. Update your Mpesa callback URL in `.env` with the ngrok URL

### Environment Variables Management

* Never commit `.env` file to version control
* Keep a `.env.example` file with dummy values for reference
* Update environment variables on your deployment platform (e.g., Heroku)

### Testing Mpesa Integration

1. Run Mpesa sandbox tests:
   ```bash
   rails test:mpesa
   ```

2. Monitor callback responses:
   ```bash
   rails mpesa:logs
   ```

## Optional Features

* Product categorization
* Quick add-to-cart functionality
* Individual item removal from cart
* Custom UI/UX design
* Payment integration

## Contributing

1. Fork the repository
2. Create your feature branch:
   ```markdown
   git checkout -b feature/new-feature
   ```
3. Commit your changes:
   ```markdown
   git commit -m 'Add new feature'
   ```
4. Push to the branch:
   ```markdown
   git push origin feature/new-feature
   ```
5. Open a Pull Request

## Resources

* [Ruby on Rails Guides](https://guides.rubyonrails.org)
* [Devise Documentation](https://github.com/heartcombo/devise)
* [Rails Directory Structure](https://guides.rubyonrails.org/getting_started.html#creating-the-blog-application)

## Technology Distribution

* Ruby: 25%
* Rails: 25%
* Front-end Development: 20%

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note:** This project is a learning exercise focused on implementing core e-commerce functionality using Ruby on Rails.
