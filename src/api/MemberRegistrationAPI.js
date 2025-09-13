import axios from 'axios';

export const registerMember = async (formData) => {
  try {
    const response = await axios.post('/api/members/register', formData);
    return response.data;
  } catch (error) {
    console.error('Registration failed:', error);
    throw error;
  }
};
