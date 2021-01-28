import { Component, OnInit } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { PostModel } from '../../../shared/model/post';
import { HeaderService } from './header.service';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css'],
  providers:[HeaderService]
})
export class HeaderComponent implements OnInit {

  postsSearch: PostModel[] = [];

  searchString: string;
  constructor(private headerService:HeaderService,private modalService: NgbModal) { }

  ngOnInit(): void {
  }

  search(searchString,content) {

    this.headerService.search(searchString).subscribe(data => {
      if (data.length > 0) {
        this.modalService.open(content, { size: 'xl' });
        this.postsSearch = data;
      }
      else {
        alert(`Không có dữ liệu cho từ khóa "${searchString}"`);
      }
    })
  }
  closeModel() {
    this.modalService.dismissAll();
  }

}
