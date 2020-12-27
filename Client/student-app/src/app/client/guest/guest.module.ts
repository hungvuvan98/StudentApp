import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { GuestRoutingModule } from './guest-routing.module';
import { HomeComponent } from './home/home.component';
import { AuthComponent } from './auth/auth.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HeaderComponent } from './header/header.component';
import { FooterComponent } from './footer/footer.component';
import { NgxCaptchaModule } from 'ngx-captcha';
import { NgxPaginationModule } from 'ngx-pagination';
import { PostComponent } from './post/post.component';
import { PostListComponent } from './post/post-list/post-list.component';
import { PostDetailComponent } from './post/post-detail/post-detail.component';
import { PostService } from './post/post.service';
import { SearchComponent } from './search/search.component';


@NgModule({
  declarations: [HomeComponent,
    AuthComponent,
    HeaderComponent,
    FooterComponent,
    PostComponent,
    PostListComponent,
    PostDetailComponent,
    SearchComponent
    
  ],
  imports: [
    CommonModule,  
    NgxCaptchaModule,
    ReactiveFormsModule,
    FormsModule,
    NgxPaginationModule,
    GuestRoutingModule,
    
  ],
  providers:[PostService]
})
export class GuestModule { }
