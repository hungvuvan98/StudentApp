import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { GuestRoutingModule } from './guest-routing.module';
import { HomeComponent } from './home/home.component';
import { AuthComponent } from './auth/auth.component';
import { FormControl, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HeaderComponent } from './header/header.component';
import { FooterComponent } from './footer/footer.component';
import { NgxCaptchaModule } from 'ngx-captcha';
import { NgxPaginationModule } from 'ngx-pagination';


@NgModule({
  declarations: [HomeComponent, AuthComponent, HeaderComponent, FooterComponent],
  imports: [
    CommonModule,  
    NgxCaptchaModule,
    ReactiveFormsModule,
    FormsModule,
    NgxPaginationModule,
    GuestRoutingModule
  ]
})
export class GuestModule { }
