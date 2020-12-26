import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { PostModel } from '../../../../shared/model/post';
import { PostService } from '../post.service';

@Component({
  selector: 'app-post-detail',
  templateUrl: './post-detail.component.html',
  styleUrls: ['./post-detail.component.css']
})
export class PostDetailComponent implements OnInit {

  post: PostModel;
  constructor(private activedRoute:ActivatedRoute,private postService:PostService) { }

  ngOnInit() {
    this.activedRoute.params.subscribe(param => {
      this.postService.getPostById(param.postId).subscribe(data => {     
        this.post = data;
      })
    })
  }

}
