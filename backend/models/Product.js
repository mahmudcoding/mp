import { sequelize, DataTypes } from './database.js';

const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT
  },
  price: {
    type: DataTypes.DECIMAL(10, 2)
  },
  condition: {
    type: DataTypes.ENUM('excellent', 'good', 'fair', 'poor')
  },
  category: {
    type: DataTypes.STRING
  },
  images: {
    type: DataTypes.TEXT // JSON string of image URLs
  },
  swapFor: {
    type: DataTypes.STRING
  },
  status: {
    type: DataTypes.ENUM('available', 'pending', 'sold'),
    defaultValue: 'available'
  }
}, {
  tableName: 'products',
  timestamps: true
});

 export default Product;