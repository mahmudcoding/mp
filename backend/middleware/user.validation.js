export const validateUser = (req, res, next) => {
  const { name, email, password } = req.body;
  
  const errors = [];
  
  if (!name) errors.push('Name is required');
  if (!email) errors.push('Email is required');
  if (!password) errors.push('password is required');
  
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }
  
  next();
};