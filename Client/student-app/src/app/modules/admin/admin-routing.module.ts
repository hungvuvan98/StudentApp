import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AdminComponent } from './admin.component';
import { StudentComponent } from './components/student/student.component';
import { ClassListComponent } from './components/class-list/class-list.component';
import { HomeComponent } from './components/home/home.component';

const adminRoutes: Routes = [
  {
    path: '',
    component: AdminComponent,
    // canActivate: [AuthGuard],
    children: [
      { path: 'homepage', component: HomeComponent },
      { path: 'student', component: StudentComponent },
      { path: 'class-list', component: ClassListComponent },
      { path: '**', component: HomeComponent },
    ]
  }
];
@NgModule({
  imports: [RouterModule.forChild(adminRoutes)],
  exports: [RouterModule]
})
export class AdminRoutingModule { }
