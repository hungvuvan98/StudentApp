import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AuthComponent } from './auth/auth.component';
import { HomeComponent } from './home/home.component';
import { PostComponent } from './post/post.component';

const routes: Routes = [
  // { path: 'login', component: AuthComponent },
  { path: '', component: HomeComponent },
  { path: 'post', component: PostComponent },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class GuestRoutingModule { }
