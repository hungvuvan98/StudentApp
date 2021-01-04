import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { PageNotFoundComponent } from './shared/page-not-found/page-not-found.component';
import { AuthGuardService } from './shared/services/auth/auth-guard.service';

const routes: Routes = [
  {
    path: '',
    loadChildren: () => import('./client/guest/guest-routing.module').then(m => m.GuestRoutingModule)
  },
  {
    path: 'student',
    loadChildren: () => import('./client/student/student-routing.module').then(m => m.StudentRoutingModule),
    canActivate:[AuthGuardService]
  },
  {
    path: 'instructor',
    loadChildren: () => import('./client/instructor/instructor-routing.module').then(m => m.InstructorRoutingModule)
  },
  // {
  //   path: 'admin',
  //   loadChildren: () => import('./admin/admin-routing.module').then(m => m.AdminRoutingModule)
  // },
  { path: 'admin', 
  loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule) },
  { path: '**', component: PageNotFoundComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
