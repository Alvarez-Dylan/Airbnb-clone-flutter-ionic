// This file can be replaced during build by using the `fileReplacements` array.
// `ng build` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

// Se usa con `ionic serve` (navegador). API real: el tunel del docente ya
// esta arriba (confirmado 2026-11-25), asi que apunta directo a ella.
export const environment = {
  production: false,
  apiUrl: 'https://api.airbnbmob2.online/api',
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.
