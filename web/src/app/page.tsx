'use client';

import React from 'react';
import { PrototypeProvider } from '../context/PrototypeContext';
import { ProductionWebLayout } from '../components/layout/ProductionWebLayout';

export default function Page() {
  return (
    <PrototypeProvider>
      <ProductionWebLayout />
    </PrototypeProvider>
  );
}

