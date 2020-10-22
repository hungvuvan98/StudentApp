import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { PageNotFoundComponent } from './common/page-not-found/page-not-found.component';
import { AuthGuardService } from './common/services/auth/auth-guard.service';

const routes: Routes = [
  { 
    path: 'admin', 
    loadChildren: () => import('./modules/admin/admin.module').then(m => m.AdminModule) ,
    // canLoad: [AuthGuard]
    canActivate:[AuthGuardService]
  }, 
  { 
    path: '',
    loadChildren: () => import('./modules/home/home.module').then(m => m.HomeModule) ,
  },
  { path: '**', component: PageNotFoundComponent }
];
  
@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

