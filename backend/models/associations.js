import User from './User.js';
import Product from './Product.js';

// User has many Products
User.hasMany(Product, { foreignKey: 'userId' });
Product.belongsTo(User, { foreignKey: 'userId' });

export { User, Product };