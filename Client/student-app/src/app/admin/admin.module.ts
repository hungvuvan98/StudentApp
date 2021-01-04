import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminRoutingModule } from './admin-routing.module';
import { AdminComponent } from './admin.component';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { RouterModule } from '@angular/router';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { NgxPaginationModule } from 'ngx-pagination';
import { FooterComponent } from './footer/footer.component';
import { NavbarComponent } from './navbar/navbar.component';
import { SidebarComponent } from './sidebar/sidebar.component';
import { StudentComponent } from './student/student.component';
import { HomeComponent } from './home/home.component';

@NgModule({
  declarations: [
    AdminComponent,
    FooterComponent, 
    NavbarComponent, 
    SidebarComponent, 
    StudentComponent, 
   HomeComponent, 
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
