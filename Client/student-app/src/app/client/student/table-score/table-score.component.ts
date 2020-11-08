import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { ScoreService } from './score.service';

@Component({
  selector: 'app-table-score',
  templateUrl: './table-score.component.html',
  styleUrls: ['./table-score.component.css'],
  providers:[ScoreService]
})
export class TableScoreComponent implements OnInit {

  detail: any[]
  result:any[]
  constructor(private scoreService:ScoreService,private auth:AuthService) { }

  ngOnInit(): void {
    this.auth.getUserId().subscribe(res => {
      this.scoreService.GetDetail(res).subscribe(res => {
        this.detail = res
      })
      this.scoreService.GetResultLearning(res).subscribe(res => {
        this.result = res
        console.log(res)
      })     
    })
  }
}
