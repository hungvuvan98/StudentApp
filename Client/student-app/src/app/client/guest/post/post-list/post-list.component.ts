import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { PostModel } from '../../../../shared/model/post';
import { PostService } from '../post.service';

@Component({
  selector: 'app-post-list',
  templateUrl: './post-list.component.html',
  styleUrls: ['./post-list.component.css']
})
export class PostListComponent implements OnInit {

  posts: PostModel[] = [];
  constructor(private postService:PostService,private activedRoute:ActivatedRoute) { }

  ngOnInit() {
    this.activedRoute.params.subscribe(res => {
      this.postService.getPostByCategory(res.categoryId).subscribe(data => {
        this.posts = data;
      })
    })  
  }

}
