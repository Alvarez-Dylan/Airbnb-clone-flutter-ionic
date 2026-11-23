import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'bo.edu.nur.bnb_arrendatario',
  appName: 'bnb Anfitriones',
  webDir: 'www',
  // En desarrollo la app llama a Mockoon por http://10.0.2.2:3001: con el
  // esquema https por defecto Android bloquea esas peticiones (no son HTTPS).
  server: {
    androidScheme: 'http',
    cleartext: true,
  },
};

export default config;
