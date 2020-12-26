import { Component, OnInit } from '@angular/core';
import { PostService } from './post.service';

@Component({
  selector: 'app-post',
  templateUrl: './post.component.html',
  styleUrls: ['./post.component.css']
})
export class PostComponent implements OnInit {

  categories: any[] = [];
  constructor(private postService:PostService) { }

  ngOnInit() {
    this.postService.getAllCategory().subscribe(listCategory => {
      this.categories = listCategory;
    })
  }
  
}
