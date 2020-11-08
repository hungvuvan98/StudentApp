import { Component, OnInit } from '@angular/core';
import { ToeicService } from './toeic.service';

@Component({
  selector: 'app-table-toeic',
  templateUrl: './table-toeic.component.html',
  styleUrls: ['./table-toeic.component.css'],
  providers:[ToeicService]
})
export class TableToeicComponent implements OnInit {

  score:any[]
  constructor(private toeicService:ToeicService) { }

  ngOnInit(): void {
    this.toeicService.getScore().subscribe(res => {
      this.score=res     
    })
  }

}
