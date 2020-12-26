import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { PostDetailComponent } from './post/post-detail/post-detail.component';
import { PostListComponent } from './post/post-list/post-list.component';
import { PostComponent } from './post/post.component';

const routes: Routes = [
  // { path: 'login', component: AuthComponent },
  { path: '', component: HomeComponent },
  {
    path: 'post',
    component: PostComponent,
    children: [
      { path: 'category/:categoryId', component: PostListComponent },
      { path: ':postId', component: PostDetailComponent },
      
    ]
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class GuestRoutingModule { }
