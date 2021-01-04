import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AdminComponent } from './admin.component';
import { HomeComponent } from './home/home.component';
import { StudentComponent } from './student/student.component';
const adminRoutes: Routes = [
  {
    path: '',
    component: AdminComponent,
    // canActivate: [AuthGuard],
    children: [
      { path: 'homepage', component: HomeComponent },
      { path: 'student', component: StudentComponent },
      { path: '**', component: HomeComponent },
    ]
  }
];
@NgModule({
  imports: [RouterModule.forChild(adminRoutes)],
  exports: [RouterModule]
})
export class AdminRoutingModule { }
