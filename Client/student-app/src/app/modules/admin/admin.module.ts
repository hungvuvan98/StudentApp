import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminRoutingModule } from './admin-routing.module';
import { AdminComponent } from './admin.component';
import { FooterComponent } from './components/footer/footer.component';
import { NavbarComponent } from './components/navbar/navbar.component';
import { SidebarComponent } from './components/sidebar/sidebar.component';
import { StudentComponent } from './components/student/student.component';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { RouterModule } from '@angular/router';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { NgxPaginationModule } from 'ngx-pagination';
import { ClassListComponent } from './components/class-list/class-list.component';
import { HomeComponent } from './components/home/home.component';

@NgModule({
  declarations: [
    AdminComponent,
    FooterComponent, 
    NavbarComponent, 
    SidebarComponent, 
    StudentComponent, 
    ClassListComponent, HomeComponent, 
  ],
  imports: [
    CommonModule,
    RouterModule,
    FormsModule,
    ReactiveFormsModule,
    AdminRoutingModule,
    NgbModule,
    NgxPaginationModule
  ],
  providers:[
  ]

})
export class AdminModule { }
