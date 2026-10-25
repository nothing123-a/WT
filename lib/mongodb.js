import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_ATLAS_URI || process.env.MONGODB_URI;

let cached = global.mongoose;

if (!cached) {
  cached = global.mongoose = { conn: null, promise: null };
}

async function connectDB() {
  if (cached.conn) {
    return cached.conn;
  }

  // Gracefully skip connecting during Next.js build / page data collection
  if (process.env.NEXT_PHASE === 'phase-production-build' || process.env.BUILDING === 'true') {
    return null;
  }

  if (!MONGODB_URI) {
    console.warn('Please define the MONGODB_URI or MONGODB_ATLAS_URI environment variable');
    return null;
  }

  if (!cached.promise) {
    const opts = {
      bufferCommands: false,
    };

    console.log('Connecting to MongoDB:', process.env.NODE_ENV === 'production' ? 'Atlas' : 'Local');
    
    cached.promise = mongoose.connect(MONGODB_URI, opts).then((mongoose) => {
      console.log('MongoDB connected successfully');
      return mongoose;
    });
  }

  try {
    cached.conn = await cached.promise;
  } catch (e) {
    cached.promise = null;
    console.error('MongoDB connection error:', e.message || e);
    if (process.env.NEXT_PHASE === 'phase-production-build') {
      return null;
    }
    throw e;
  }

  return cached.conn;
}

export default connectDB;